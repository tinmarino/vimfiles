# Imagen de prueba: valida que la config de vimfiles del usuario
# funcione en un Ubuntu pelado con vim + tmux.
# Contexto de build = ~/.vim (ver test/ubuntu.sh).
# El .dockerignore asociado (test/ubuntu.dockerfile.dockerignore) excluye
# .git (tiene un remote con token: NUNCA se copia), undo/, plugged/, etc.
FROM ubuntu:24.04

# Sin interaccion en apt y sin GUI
ENV DEBIAN_FRONTEND=noninteractive

# Minimo razonable: vim, tmux, git, curl, bash, locales y xclip.
# (bc queda fuera a proposito: la config debe tolerar su ausencia.)
RUN apt-get update && apt-get install -y --no-install-recommends \
        vim tmux git curl bash locales xclip ca-certificates \
    && sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
    && locale-gen \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Usuario no-root para probar como lo haria una persona real
RUN useradd --create-home --shell /bin/bash tester
USER tester
WORKDIR /home/tester

# Copiamos el ~/.vim local (NO clonamos el remoto para no arrastrar el token)
COPY --chown=tester:tester . /home/tester/.vim/

# install.sh es idempotente y no aborta si algo opcional falla (xrdb, etc.)
RUN bash /home/tester/.vim/dotfile/install.sh || true

# Por defecto corremos el test
CMD ["bash", "/home/tester/.vim/test/ubuntu_test.sh"]
