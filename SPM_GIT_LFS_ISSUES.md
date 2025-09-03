# Swift Package Manager Git LFS Issues

This document explains the problems we encountered when distributing the VLCKit Swift Package with Git LFS and the solutions we found.

## Problem Summary

VLCKit includes a large (~851MB) MobileVLCKit.xcframework that we store using Git LFS. While manual `git clone` operations work perfectly, Swift Package Manager (SPM) fails to resolve the package dependencies with the error:

```
Error downloading object: MobileVLCKit.xcframework/Info.plist (32e6837): 
Smudge error: error transferring "32e6837d6d38ba22ff1241b159700d2dbd10bd417da1819869062252d95f02ed": 
[0] remote missing object 32e6837d6d38ba22ff1241b159700d2dbd10bd417da1819869062252d95f02ed
```

## Root Cause Analysis

Through detailed investigation, we found the issue is NOT authentication-related, despite what the error suggests. Here's what we discovered:

### 1. Normal Git vs SPM Git Environment Differences

**Normal Git LFS Environment:**
```
Endpoint=https://github.com/rsalesas/VLCKit.git/info/lfs (auth=basic)
AccessDownload=basic
AccessUpload=basic
```

**SPM's Git LFS Environment:**
```
Endpoint=file:///Users/.../SourcePackages/repositories/VLCKit-xxx (auth=none)
AccessDownload=none
AccessUpload=none
GIT_TERMINAL_PROMPT=0
GIT_SSH_COMMAND=ssh -oBatchMode=yes
```

### 2. The Real Problem: Empty LFS Cache

SPM uses a **bare repository cache** structure:
```
~/Library/Developer/Xcode/DerivedData/PROJECT/SourcePackages/
├── repositories/
│   └── VLCKit-xxx/           # Bare repository
│       └── lfs/objects/      # EMPTY - this is the problem
└── checkouts/
    └── VLCKit/               # Working copy
```

**The Issue:** SPM's Git client downloads the repository metadata but fails to populate the LFS objects in the bare repository cache. When checking out files, it looks for LFS objects locally (file:// endpoint) instead of fetching from GitHub (https:// endpoint), finds nothing, and fails.

### 3. Why Manual Clone Works vs SPM Fails

- **Manual clone:** Uses interactive authentication, fetches LFS objects directly from GitHub
- **SPM:** Uses non-interactive mode with local file lookups, never populates the LFS cache

## Current Workaround Solution

### Manual Fix (Not Recommended)

1. Let SPM fail initially
2. Manually populate the LFS cache:
```bash
cd "~/Library/Developer/Xcode/DerivedData/PROJECT/SourcePackages/repositories/VLCKit-xxx"
git lfs fetch --all
```
3. Re-run SPM resolution - it will now succeed

### Why This Is Not a Good Solution

1. **Manual intervention required** - Every developer must perform this workaround
2. **Cache invalidation** - Xcode often clears derived data, requiring repeated fixes
3. **CI/CD unfriendly** - Automated builds will fail without manual intervention
4. **Not discoverable** - New team members will encounter cryptic errors
5. **Xcode version dependent** - Cache locations and behavior may change

## Better Long-term Solutions

### Option 1: GitHub Releases with Direct Downloads (Recommended)

Convert the Package.swift to use URL-based binary targets:

```swift
.binaryTarget(
    name: "MobileVLCKit",
    url: "https://github.com/rsalesas/VLCKit/releases/download/3.6.3/MobileVLCKit.xcframework.zip",
    checksum: "sha256-checksum-here"
)
```

**Pros:**
- No Git LFS issues
- Works reliably with SPM
- Cacheable by SPM
- CI/CD friendly

**Cons:**
- Requires GitHub Releases workflow
- Manual checksum calculation
- Larger repository download for contributors (unless we .gitignore the framework)

### Option 2: XCFramework Distribution via CocoaPods Specs

Keep using CocoaPods' proven binary distribution infrastructure:

```swift
.package(url: "https://github.com/CocoaPods/Specs.git", from: "1.0.0")
```

**Pros:**
- Leverages existing CocoaPods infrastructure
- No LFS issues
- Proven at scale

**Cons:**
- Adds CocoaPods dependency
- More complex setup

### Option 3: Swift Package Registry (Future)

When Apple's Swift Package Registry becomes available, migrate to it for proper binary distribution.

## Technical Details for Future Reference

### SPM Cache Structure
```
~/Library/Developer/Xcode/DerivedData/
└── PROJECT-hash/
    └── SourcePackages/
        ├── repositories/
        │   └── VLCKit-hash/          # Bare repo cache
        │       ├── config
        │       ├── objects/
        │       └── lfs/
        │           └── objects/      # Must be populated manually
        └── checkouts/
            └── VLCKit/               # Working directory
```

### Key Environment Variables in SPM Context
- `GIT_TERMINAL_PROMPT=0` - Disables interactive prompts
- `GIT_SSH_COMMAND=ssh -oBatchMode=yes` - Forces batch mode
- LFS endpoint becomes local file:// instead of remote https://

### Diagnostic Commands

Check LFS environment in SPM checkout:
```bash
cd ~/Library/Developer/Xcode/DerivedData/PROJECT/SourcePackages/checkouts/VLCKit
git lfs env
```

Check LFS objects in SPM cache:
```bash
ls -la ~/Library/Developer/Xcode/DerivedData/PROJECT/SourcePackages/repositories/VLCKit-*/lfs/objects/
```

Check for specific missing object:
```bash
find ~/Library/Developer/Xcode/DerivedData/PROJECT/SourcePackages/repositories/VLCKit-*/lfs/objects/ -name "*32e6837*"
```

## Recommendation

We recommend moving to **GitHub Releases with direct download URLs** (Option 1) as it provides the most reliable and maintainable solution for distributing large binary frameworks via Swift Package Manager.

---

*This document was created after extensive debugging of SPM Git LFS issues encountered while integrating VLCKit 3.6.3 into a Swift project.*