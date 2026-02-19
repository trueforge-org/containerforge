# Sweep Status

- Timestamp (UTC): 2026-02-19T17:36:22Z
- Build: fail
- Forgetool test: skip
- Run status: not running
- Timeout for build/test: 120 seconds
- Forgetool path: /tmp/forgetool-bin/forgetool

## Last build log tail
```
#7 85.91 To address issues that do not require attention, run:
#7 85.91   npm audit fix
#7 85.91 
#7 85.91 To address all issues, run:
#7 85.91   npm audit fix --force
#7 85.91 
#7 85.91 Run `npm audit` for details.
#7 85.91 npm notice
#7 85.91 npm notice New major version of npm available! 10.9.4 -> 11.10.0
#7 85.91 npm notice Changelog: https://github.com/npm/cli/releases/tag/v11.10.0
#7 85.91 npm notice To update run: npm install -g npm@11.10.0
#7 85.91 npm notice
#7 85.99 **** cleanup ****
#7 85.99 Reading package lists...
#7 86.75 Building dependency tree...
#7 86.90 Reading state information...
#7 87.06 0 upgraded, 0 newly installed, 0 to remove and 2 not upgraded.
#7 DONE 88.3s

#8 [3/5] COPY . /
#8 DONE 0.3s

#9 [4/5] COPY ./root /
#9 DONE 0.0s

#10 [5/5] WORKDIR /config
#10 DONE 0.0s

#11 exporting to image
#11 exporting layers
#11 exporting layers 17.7s done
#11 exporting manifest sha256:72d9d15fc0561e77cb085f909d6f192ebe3caf4d9d0dd613561d87da34b306bb done
#11 exporting config sha256:3bc5ba273431f008678ac4b9910fba10b06e819f37e2a3a45f0d64c2fead879f done
#11 exporting attestation manifest sha256:9a12a21fc821515a14079cf0154651bc1121e646fb2796cbf29529bc519ff385 done
#11 exporting manifest list sha256:4d718e51a6d0bd157e4f1c6f0fcea3d45508a5528683aab6cebc139335863bd0 done
#11 naming to docker.io/library/raneto:0.18.0 done
#11 unpacking to docker.io/library/raneto:0.18.0
#11 unpacking to docker.io/library/raneto:0.18.0 1.2s done
#11 CANCELED
ERROR: failed to solve: Canceled: context canceled
```
