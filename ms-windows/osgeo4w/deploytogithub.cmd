@echo off
REM ***************************************************************************
REM    deploytogithub.cmd
REM    ---------------------
REM    begin                : January 2020
REM    copyright            : (C) 2020 by Matthias Kuhn
REM    email                : matthias@opengis.ch
REM ***************************************************************************
REM *                                                                         *
REM *   This program is free software; you can redistribute it and/or modify  *
REM *   it under the terms of the GNU General Public License as published by  *
REM *   the Free Software Foundation; either version 2 of the License, or     *
REM *   (at your option) any later version.                                   *
REM *                                                                         *
REM ***************************************************************************

setlocal enabledelayedexpansion

set RELEASE_DIR=%2
set VERSION=%1

call "%OSGEO4W_ROOT%\bin\o4w_env.bat"
call "%OSGEO4W_ROOT%\bin\py3_env.bat"
call "%OSGEO4W_ROOT%\bin\qt5_env.bat"

python -m pip install pygithub
python ..\..\scripts\upload_release_asset.py file.zip v1.4.1
