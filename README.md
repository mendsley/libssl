# Building OpenSSL

Building OpenSSL is a pain. Especially for any platform besides Linux.

Let's fix that.

1. Download and extact an openssl release tarbar into
the folder openssl_tarball. The file openssl_tarball/Makefile
should exist. If it doesn't you did something wrong.

2. Use premake5 to generate the public openssl includes
`premake openssl_headers` -> include/openssl

2. Use premake5 to generate your project file:

*Visual Studio 2010*
`premake5 vs2010` -> .build/projects/libssl.sln

*GNU Make*
`premake5 gmake` -> .build/projects/makefile

Build.

The example configurations generate static libraries in the
lib/ folder

Advanced  (using in your own solution)
--------------------------------------

I'm making the assumption that you're already using premake5 to
generate your projects.

1. Copy the OpenSSL module to your project (./modules/openssl)
2. Include it via the `include` directive (see premake5.lua)
3. Use the premake.extensions.openssl functions to handle project/header
generation

Contact
-------
[@\_boblan\_](https://twitter.com/#!/_boblan_)  
<https://github.com/mendsley/libssl>

Licenses
--------
This project is governed by the BSD 2-clause license. For details see the file
titled LICENSE in the project root folder.

OpenSSL
-------
For OpenSSL see [http://www.openssl.org/source/license.html](http://www.openssl.org/source/license.html).

premake5
--------
Copyright (c) 2003-2014 Jason Perkins and individual contributors.
All rights reserved.

Binaries are distributed under the BSD-3 clause license (see LICENSE_premake5).

See [http://industriousone.com/premake](http://industriousone.com/premake) for
details.
