FROM almalinux:8 as base
RUN dnf install -y @development epel-release && \
    dnf config-manager --set-enabled powertools && \
    dnf clean all

FROM base as devel
ARG EOS_SOURCE_TARBALL
ADD $EOS_SOURCE_TARBALL /src/eos
RUN dnf builddep -y /src/eos/EosKernel-*.src.rpm && \
    dnf install -y gcc-toolset-14 pax python39 python39-devel rsync && \
    alternatives --set python /usr/bin/python3 && \
    alternatives --set python3 /usr/bin/python3.9 && \
    rpm -i /src/eos/EosKernel-*.src.rpm && \
    dnf clean all
WORKDIR /root/rpmbuild/SPECS
# Linux 5.x requires AlmaLinux's native compiler, while Linux 6.x requires GCC 14.
RUN if [ "$(rpm -qp --qf '%{version}' /src/eos/EosKernel-*.src.rpm | cut -d. -f1)" -ge 6 ]; then \
        . /opt/rh/gcc-toolset-14/enable; \
    fi && \
    sed -i 's/^diff /true /;s/\(%define modules_main\) .*/\1 \/usr\/lib\/modules/;/modules.builtin.alias.bin/d' EosKernel.spec && \
    sed -i 's/ Patch 20940//' ../SOURCES/arista-BUG390058-bcm5720-force-ncsi-passthrough.patch && \
    sed -i 's~/usr/bin/dracut ~true ~' EosKernel.spec && \
    sed -i '\~^/boot/initramfs-microvm-~d' EosKernel.spec && \
    rpmbuild -bb --define="release $(rpm -qp --qf '%{release}' /src/eos/EosKernel-*.src.rpm)" EosKernel.spec && \
    rpm -i --nodeps ../RPMS/x86_64/EosKernel-[0-9]*.rpm ../RPMS/x86_64/EosKernel-devel-*.rpm

FROM devel as build
ARG KERNEL_MODULE_PATH
ARG KERNEL_MODULE_SOURCE
ADD $KERNEL_MODULE_SOURCE /src/module
RUN if [ "$(rpm -qp --qf '%{version}' /src/eos/EosKernel-*.src.rpm | cut -d. -f1)" -ge 6 ]; then \
        . /opt/rh/gcc-toolset-14/enable; \
    fi && \
    make -C /usr/src/kernels/EosKernel M=/src/module/${KERNEL_MODULE_PATH} KCFLAGS=-Wno-error modules && \
    INSTALL_MOD_PATH=/install make -C /usr/src/kernels/EosKernel M=/src/module/${KERNEL_MODULE_PATH} modules_install

FROM scratch as output
COPY --from=build /install/ /
