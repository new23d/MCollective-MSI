@echo off
setlocal enabledelayedexpansion

set var_puppet_key_name="HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Puppet Labs\Puppet"
set var_puppet_value_name="RememberedInstallDir"

for /f "usebackq skip=1 tokens=1,2*" %%a in (`reg query %var_puppet_key_name% /v %var_puppet_value_name%`) do (set var_puppet_base_dir=%%c)

set var_mcollective_base_dir=%ProgramFiles(x86)%\MCollective\
set var_mcollective_etc_dir=%ProgramData%\MCollective\etc\

set var_programfilesx86_dir=%ProgramFiles(x86)%

call "%var_puppet_base_dir%bin\environment.bat"

"%var_puppet_base_dir%sys\ruby\bin\ruby.exe" -I"%var_mcollective_base_dir%lib;%var_puppet_base_dir%puppet\lib;%var_puppet_base_dir%facter\lib;%var_puppet_base_dir%hiera\lib;" -- "%var_mcollective_base_dir%opt\facter_cef.rb"