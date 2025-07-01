FROM almalinux:8 as base
RUN dnf install -y @development epel-release && \
    dnf config-manager --set-enabled powertools && \
    dnf clean all

FROM base as devel
ARG EOS_SOURCE_TARBALL
ADD $EOS_SOURCE_TARBALL /src/eos
RUN dnf builddep -y /src/eos/EosKernel-*.src.rpm && \
    dnf install -y pax rsync && \
    alternatives --set python /usr/bin/python3 && \
    rpm -i /src/eos/EosKernel-*.src.rpm && \
    dnf clean all
WORKDIR /root/rpmbuild/SPECS
RUN sed -i 's/^diff /true /;s/\(%define modules_main\) .*/\1 \/usr\/lib\/modules/;/modules.builtin.alias.bin/d' EosKernel.spec && \
    sed -i 's/ Patch 20940//' ../SOURCES/arista-BUG390058-bcm5720-force-ncsi-passthrough.patch && \
    sed -i 's~/usr/bin/dracut ~true ~' EosKernel.spec && \
    sed -i '\~^/boot/initramfs-microvm-~d' EosKernel.spec && \
    rpmbuild -bb --define="release $(rpm -qp --qf '%{release}' /src/eos/EosKernel-*.src.rpm)" EosKernel.spec && \
    rpm -i --nodeps ../RPMS/x86_64/EosKernel-[0-9]*.rpm ../RPMS/x86_64/EosKernel-devel-*.rpm

FROM devel as build
ARG KERNEL_MODULE_PATH
ARG KERNEL_MODULE_SOURCE
ADD $KERNEL_MODULE_SOURCE /src/module
RUN make -C /usr/src/kernels/EosKernel M=/src/module/${KERNEL_MODULE_PATH} modules && \
    INSTALL_MOD_PATH=/install make -C /usr/src/kernels/EosKernel M=/src/module/${KERNEL_MODULE_PATH} modules_install

FROM scratch as output
COPY --from=build /install/ /
