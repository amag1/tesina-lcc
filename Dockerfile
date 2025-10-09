FROM texlive/texlive:latest

# Install additional system packages
RUN apt-get update && apt-get install -y \
    python3-pygments \
    fontconfig \
    wget \
    unzip \
    ghostscript \
    fonts-liberation \
    fonts-dejavu \
    fonts-noto \
    file \
    && rm -rf /var/lib/apt/lists/*

# Install fonts in separate steps for better debugging
RUN mkdir -p /usr/local/share/fonts

# Install IBM Plex fonts
RUN cd /tmp && \
    wget -q -O plex.zip https://github.com/IBM/plex/releases/download/v6.4.0/OpenType.zip && \
    unzip -q plex.zip -d plex-fonts && \
    find plex-fonts -name "*.otf" -exec cp {} /usr/local/share/fonts/ \; && \
    rm -rf plex*

# Install EB Garamond (alternative source)
RUN cd /tmp && \
    wget -q -O garamond.zip https://github.com/georgd/EB-Garamond/archive/refs/heads/master.zip && \
    unzip -q garamond.zip -d garamond-fonts && \
    find garamond-fonts -name "*.otf" -o -name "*.ttf" -exec cp {} /usr/local/share/fonts/ \; && \
    rm -rf garamond*

# Use alternative font sources that are more reliable
RUN cd /tmp && \
    # Install Lato from alternative source
    wget -q -O lato.zip https://github.com/google/fonts/archive/main.zip && \
    unzip -q lato.zip && \
    find fonts-main -path "*/lato/*" -name "*.ttf" -exec cp {} /usr/local/share/fonts/ \; && \
    # Install Crimson Text from alternative source  
    find fonts-main -path "*/crimsontext/*" -name "*.ttf" -exec cp {} /usr/local/share/fonts/ \; && \
    rm -rf fonts-main lato.zip

# Refresh font cache
RUN fc-cache -fv

WORKDIR /workspace