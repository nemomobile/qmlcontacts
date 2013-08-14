# 
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.26
# 

Name:       qmlcontacts

# >> macros
# << macros

Summary:    Contacts application for nemo
Version:    0.4.2
Release:    1
Group:      Applications/System
License:    GPLv2
URL:        https://github.com/nemomobile/qmlcontacts
Source0:    %{name}-%{version}.tar.gz
#Source100:  qmlcontacts-qt5.yaml
Requires:   qt-components-qt5 >= 1.4.8
Requires:   mapplauncherd-booster-qtcomponents-qt5
Requires:   nemo-qml-plugin-thumbnailer-qt5
Requires:   nemo-qml-plugin-contacts-qt5
Requires:   nemo-qml-plugin-folderlistmodel
Requires:   qmlgallery
Requires:   qmlfilemuncher
Requires:   contactsd
Requires:   nemo-qml-plugin-dbus-qt5
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Contacts)
BuildRequires:  pkgconfig(qdeclarative5-boostable)
BuildRequires: qt5-qtgui-devel
BuildRequires: qt5-qtwidgets-devel
BuildRequires: qt5-qtquick-devel
# BuildRequires:  desktop-file-utils
Provides:   meego-handset-people > 0.2.32
Provides:   meego-handset-people-branding-upstream > 0.2.32
Obsoletes:   meego-handset-people <= 0.2.32
Obsoletes:   meego-handset-people-branding-upstream <= 0.2.32

%description
Contacts application using Qt Quick for Nemo Mobile.

%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

qmake -qt=5 -recursive

make %{?jobs:-j%jobs}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake_install

# >> install post
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_bindir}/qmlcontacts
%{_datadir}/applications/qmlcontacts.desktop
%{_libdir}/qt5/qml/org/nemomobile/qmlcontacts/*
# >> files
# << files
