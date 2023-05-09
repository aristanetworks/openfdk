#-------------------------------------------------------------------------------
#- Copyright (c) 2021 Arista Networks, Inc. All rights reserved.
#-------------------------------------------------------------------------------
#- Author:
#-   fdk-support@arista.com
#-
#- Description:
#-   .spec file to build an example app.
#-
#-   Licensed under BSD 3-clause license:
#-     https://opensource.org/licenses/BSD-3-Clause
#-
#- Tags:
#-   license-arista-fdk-agreement
#-   license-bsd-3-clause
#-
#-------------------------------------------------------------------------------

%if 0%{?stubrpm:1}
Name:           %{appname}-stub
Provides:       %{appname}
Conflicts:      %{appname}
%else
Name:           %{appname}
Conflicts:      %{appname}-stub
%endif
Version:        %{version}
Release:        %{release}
Summary:        %{summary}

License:        Commercial
Source:         %{source}

AutoReqProv:    no

%description
%{appname}

%prep
%setup -n %{appname} -q

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
cp -a . %{buildroot}
%if 0%{?stubrpm:1}
rm -rf %{buildroot}/opt/apps/%{appname}/*
%endif

%files
%if 0%{?stubrpm:1}
%dir /opt/apps/%{appname}
%else
/opt/apps/%{appname}
%endif
%if 0%{?extradirs:1}
%include %{extradirs}
%endif

%changelog

%if 0%{?stubrpm:1}
%pre
# this ensures that the overlayfs is unmounted prior to upgrade if replacing
# an older swix which was built before overlayfs support was added
if mountpoint -q %{appdir}; then
    lowerdir=$(sed -nre "s@^overlay %{appdir} overlay .*,lowerdir=([^,]+).*@\1@p" < /proc/mounts)
    umount %{appdir}
    if [ -n "${lowerdir}" ] && mountpoint -q ${lowerdir}; then
        umount ${lowerdir}
    fi
fi
%endif

%post
#if [ -d /opt/apps/%{appname}/www ]; then
#    ln -sf /opt/apps/%{appname}/www /usr/share/nginx/html/apps/%{appname}
#fi
for d in /usr/lib/python[23].*/site-packages; do
    ln -sf /opt/apps/%{appname} $d/%{appname}
%if 0%{?cliplugins:1}
    mkdir -p $d/CliPlugin
    ln -sf %{cliplugins} $d/CliPlugin/
%endif
done

exit 0

%preun
if [ $1 == 0 ]; then
    # uninstalling
    for d in /usr/share/nginx/html/apps /usr/lib/python[23].*/site-packages; do
        if [ -L $d/%{appname} ]; then
            rm -f $d/%{appname}
        fi
%if 0%{?cliplugins:1}
        for p in $(basename -a %{cliplugins}); do
            f=$d/CliPlugin/$p
            if [ -L $f ]; then
                rm -f $f
                # remove .pyc files too
                case $f in *.py) rm -f ${f}c ;; esac
            fi
        done
%endif
    done
%if 0%{?stubrpm:1}
    if mountpoint -q %{appdir}; then
        lowerdir=$(sed -nre "s@^overlay %{appdir} overlay .*,lowerdir=([^,]+).*@\1@p" < /proc/mounts)
        umount %{appdir}
        if [ -n "${lowerdir}" ] && mountpoint -q ${lowerdir}; then
            umount ${lowerdir}
        fi
    fi
%endif
fi
exit 0
