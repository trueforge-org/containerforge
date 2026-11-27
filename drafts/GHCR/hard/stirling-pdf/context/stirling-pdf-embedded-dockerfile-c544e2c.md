# Stirling-PDF docker/embedded/Dockerfile at c544e2c (full embedded version)
Source URL: https://raw.githubusercontent.com/Stirling-Tools/Stirling-PDF/c544e2c3457f52d05675b36dffacc44a4479149e/docker/embedded/Dockerfile (fetched 2026-11-27)

## Build args
- BASE_VERSION=1.1.1@sha256:6b57e965506d61170851d6e85e4ff1a29fbc66db4fc4bf3d78c0e31fd1fb32ae
- BASE_IMAGE=stirlingtools/stirling-pdf-base:${BASE_VERSION}
- TASK_VERSION=3.54.0 (go-task .deb), NODE_MAJOR_VERSION=24
- FORM_DETECTION_MODEL_URL (huggingface Frooodle/ffdetr-int8 onnx, pinned commit), _SHA256 de43bb39..., _ID ffdetr
- STIRLING_FLAVOR=proprietary; BUILD_PORTAL=true; VITE_SUPABASE_URL, VITE_SUPABASE_PUBLISHABLE_DEFAULT_KEY, VITE_SAAS_API_URL, VITE_ACCESSIBILITY_EDITING (all default "")
- TARGETARCH (linux-arm64 or linux-x64 for JPDFium)
- VERSION_TAG (runtime stage)

## Stage 1 app-build
- FROM gradle:9.7.1-jdk25@sha256:e06837...eb093
- installs curl, ca-certificates, nodejs 24 (nodesource), go-task .deb from github releases
- downloads and sha256-checks ffdetr model into /preinstalled-models/
- ENV JDK_JAVA_OPTIONS with --add-exports for jdk.compiler javac packages (JDK 25 note: not JAVA_TOOL_OPTIONS)
- WORKDIR /app; copies gradle files then `gradle dependencies --no-daemon || true`, then COPY . .
- `gradle clean build -PbuildWithFrontend=true -PbuildWithPortal=... -PjpdfiumPlatforms=... -PbundleOnnxRuntime=true -x spotlessApply -x spotlessCheck -x test -x sonarqube --no-daemon`

## Stage 2 jar-extract
- FROM eclipse-temurin:25-jre-noble@sha256:a98128a5...
- `java -Djarmode=tools -jar app.jar extract --layers --destination /layers`
- scripts/slim-onnxruntime.sh strips ONNX natives to target arch

## Stage 3 runtime (FROM ${BASE_IMAGE})
- WORKDIR /app; COPY --link layers owned 1000:1000 into /app/
- /restart-helper.jar, /scripts/ (chmod +x), /opt/stirling/preinstalled-models/
- fonts to /usr/share/fonts/truetype/
- symlinks /app/{logs,configs,customFiles,pipeline,storage} -> /logs,/configs,/customFiles,/pipeline,/storage; chown stirlingpdfuser:stirlingpdfgroup
- /tmp/stirling-pdf chmod 750; heap_dumps 750; fc-cache -f
- /etc/stirling_version written from VERSION_TAG

## ENV (runtime)
| env | value |
| --- | --- |
| VERSION_TAG | $VERSION_TAG |
| FORMDETECTION_PREINSTALLEDMODELDIR | /opt/stirling/preinstalled-models |
| ORT_DISABLE_TELEMETRY | 1 |
| STIRLING_AOT_ENABLE | "false" |
| _JVM_OPTS | ExitOnOutOfMemoryError, HeapDumpOnOutOfMemoryError, HeapDumpPath=/configs/heap_dumps, G1GC tuning, UseCompactObjectHeaders, virtual threads, headless |
| JAVA_CUSTOM_OPTS | "" |
| HOME | /home/stirlingpdfuser |
| PUID / PGID | 1000 / 1000 |
| UMASK | 022 |
| STIRLING_TEMPFILES_DIRECTORY, TMPDIR, TEMP, TMP | /tmp/stirling-pdf |
| DBUS_SESSION_BUS_ADDRESS | /dev/null |
| SAL_TMP | /tmp/stirling-pdf/libre |

## Ports / signals / health
- EXPOSE 8080/tcp; STOPSIGNAL SIGTERM
- HEALTHCHECK interval 30s, timeout 15s, start-period 120s, retries 5: `curl -fs --max-time 10 http://localhost:8080${SYSTEM_ROOTURIPATH:-''}/api/v1/info/status`
- ENTRYPOINT ["tini", "--", "/scripts/init.sh"]; CMD []

## User
- No USER line in this file; runtime user `stirlingpdfuser` (uid/gid 1000 via PUID/PGID) is provided by the base image (definition not in this file)

## Labels
- licenses MIT; source github Stirling-Tools/Stirling-PDF; documentation https://docs.stirlingpdf.com

## Gotchas
- Vite VITE_* build args must stay empty to use committed frontend defaults; overriding VITE_SAAS_API_URL requires matching STIRLING_BILLING_ACCOUNT_LINK_SAAS_BASE_URL at runtime (per file comments)
- Model file sha256-verified at build time
