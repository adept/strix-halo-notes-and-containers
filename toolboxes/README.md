# ROCm 7.2 Container with whisper.cpp, llama.cpp and llama-swap

llama-swap listens on :8080 and routes requests to llama.cpp and whisper.cpp. It also handles models loading/unloading to ensure that we dont run out of VRAM.

Container is based on [@kyuz0's rocm 7.2 toolbox](https://github.com/kyuz0/amd-strix-halo-toolboxes/blob/main/toolboxes/Dockerfile.rocm-7.2), with dev stage extended to build whisper.cpp,
and runtime stage extended to include a prebuilt static `ffmpeg` (so that whisper.cpp could convert incoming audio files to .wav) and prebuilt `llama-swap`.

This assumes some level of familiarity with linux, containers, etc etc

Use `build.sh` to build the container, and `run.sh` to run it. When it runs, go to `http://<strix-halo-host>:8080/ui` to access llama-swap ui, which provides basic chat interface, access to logs, etc etc.
