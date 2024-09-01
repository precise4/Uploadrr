# Stage 1: Build Stage
FROM alpine:latest AS build

# Install build dependencies and tools
RUN apk add --no-cache \
    python3 \
    python3-dev \
    py3-pip \
    cargo \
    rust \
    g++ \
    python3-tkinter \
    git

# Create virtual environment
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Install Python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . /app

# Stage 2: Final Image
FROM alpine:latest AS runtime

RUN apk add --no-cache mono --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing

# Install runtime dependencies
RUN apk add --no-cache \
    ffmpeg \
    mediainfo \
    mktorrent \
    mono \
    python3 \
    python3-tkinter

# Copy virtual environment and application code from the build stage
COPY --from=build /venv /venv
COPY --from=build /app /app

# Set environment variables
ENV PATH="/venv/bin:$PATH"

VOLUME ["/videos"]
WORKDIR /videos

# Set the entry point for the container
ENTRYPOINT ["/venv/bin/python3", "/app/upload.py"]
