@echo off
setlocal enabledelayedexpansion

if defined ProgramData (
  set var_platform_program_data=%ProgramData%
)

if not defined ProgramData (
  set var_platform_program_data=%ALLUSERSPROFILE%\Application Data
)

if defined ProgramFiles(x86) (
  set "var_programfilesx86_dir=%ProgramFiles(x86)%"
  set var_puppet_key_name="HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Puppet Labs\Puppet"
)

if not defined ProgramFiles(x86) (
  set var_programfilesx86_dir=%ProgramFiles%
  set var_puppet_key_name="HKEY_LOCAL_MACHINE\SOFTWARE\Puppet Labs\Puppet"
)

set var_puppet_value_name="RememberedInstallDir"

for /f "usebackq skip=1 tokens=1,2*" %%a in (`reg query %var_puppet_key_name% /v %var_puppet_value_name%`) do (set var_puppet_base_dir=%%c)

set var_mcollective_base_dir=!var_programfilesx86_dir!\MCollective\
set var_mcollective_etc_dir=%var_platform_program_data%\MCollective\etc\

if not exist "%var_mcollective_etc_dir%server.cfg" (
echo ^
main_collective = mcollective^

#collectives = mcollective,gotham_collective^

libdir = !var_programfilesx86_dir!\MCollective\plugins^

logfile = %var_platform_program_data%\MCollective\var\log\server.log^

loglevel = debug^

daemonize = 1^

^

securityprovider = psk^

plugin.psk = pass%RANDOM%word^

^

connector = rabbitmq^

direct_addressing = 1^

plugin.rabbitmq.vhost = mcollective^

^

plugin.rabbitmq.pool.1.host = rabbitmq.example.com^

plugin.rabbitmq.pool.1.user = joe^

plugin.rabbitmq.pool.1.password = pass%RANDOM%word^

plugin.rabbitmq.pool.1.port = 61613^

^

plugin.rabbitmq.pool.size = 1^

^

factsource = facter^

plugin.facter.facterlib = %var_platform_program_data%\PuppetLabs\puppet\var\lib\facter^

^

#identity = %COMPUTERNAME%.example.com^

^

#registerinterval = 600^

#registration = agentlist^

#registration_collective = mcollective^

^

rpcaudit = 1^

rpcauditprovider = logfile^

plugin.rpcaudit.logfile = %var_platform_program_data%\MCollective\var\log\audit.log^

^

classesfile = %var_platform_program_data%\PuppetLabs\puppet\var\state\classes.txt^

> "%var_mcollective_etc_dir%server.cfg"
)

call "%var_puppet_base_dir%bin\environment.bat"

"%var_puppet_base_dir%sys\ruby\bin\ruby.exe" -I"%var_mcollective_base_dir%lib;%var_puppet_base_dir%puppet\lib;%var_puppet_base_dir%facter\lib;%var_puppet_base_dir%hiera\lib;" -- "%var_mcollective_base_dir%bin\mcollectived" --config "%var_mcollective_etc_dir%server.cfg"