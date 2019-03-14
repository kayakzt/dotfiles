@echo off

for /f %%e in ('type "\.extensions"') do (
    call code --install-extension %%e
)
goto :EOF
