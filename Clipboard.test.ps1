Import-Module $PSScriptRoot/lesspass.psd1 -Force  # force code to be reloaded

Clear-Host

Describe 'Clipboard' {
    Context "Check" {
        $CopyCommand = Get-SystemCopyCommand

        It 'copy executable is present' {
            {$CopyCommand.CommandType} | Should -not -Throw
        }
    }
}