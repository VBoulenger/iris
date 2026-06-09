FROM python:3.11-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# 1. Install system dependencies (including C compilers needed for heavy libs)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gdal-bin \
    libgdal-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 2. Required for rasterio/GDAL to find system libraries properly
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal

# 3. Install uv automatically using its official installer
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

# 4. Leverage Docker caching for dependencies
COPY requirements.txt .
RUN uv pip install --system --no-cache -r requirements.txt

# 5. Copy and install the actual application
COPY . .
RUN uv pip install --system --editable .

ENTRYPOINT ["iris"]
