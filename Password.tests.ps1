Import-Module $PSScriptRoot/Password.psm1 -Force  # force code to be reloaded
Describe 'Rendder Password' {
    Context "GetConfiguredRules" {
        It "is empty when no rules in profile" {
            $PasswordProfile = @{}
            
            GetConfiguredRules $PasswordProfile | Should -Be @()
        }

        It "ignore disabled rules" {
            $PasswordProfile = @{
                lowercase = $False
                uppercase = $True
                digits    = $False
                symbols   = $True
            }
            
            GetConfiguredRules $PasswordProfile | Should -Be @("uppercase", "symbols")
        }

        It "preserve rules order" {
            $PasswordProfile = @{
                lowercase = $True
                uppercase = $True
                digits    = $True
                symbols   = $True
            }
            
            GetConfiguredRules $PasswordProfile | Should -Be @("lowercase", "uppercase", "digits", "symbols")
        }
    }

    Context "GetSetOfCharacters" {
        $CharacterSubsets = [ordered]@{
            lowercase = "abcdefghijklmnopqrstuvwxyz"
            uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            digits    = "0123456789"
            symbols   = "!`"#$%&'()*+,-./:;<=>?@[`\]^_``{|}~"
        }

        It "get set of characters without rule" {
            GetSetOfCharacters @() | Should -BeExactly "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!`"#$%&'()*+,-./:;<=>?@[\]^_``{|}~"
        }

        It "get set of characters with single rule: <rule>"-TestCases @(
            @{rule = "lowercase" }
            @{rule = "uppercase" }
            @{rule = "digits" }
            @{rule = "symbols" }
         ) {
            param($rule)
            GetSetOfCharacters @($rule) | Should -BeExactly $CharacterSubsets.$rule

        }

        It "get set of characters with several rules" {
            GetSetOfCharacters @("lowercase", "digits") | Should -BeExactly "abcdefghijklmnopqrstuvwxyz0123456789"
        }
    }

    Context "ConsumeEntropy" {
        $GeneratedPassword = ""
        # declaring BigInt as a string is mandatory, see https://stackoverflow.com/q/55366362/802365
        [BigInt]$EntropyAsInt = "99600400399777174105034830393873797761817714609490038944205586760025858632478"
        
        $SetOfCharacters = "abcdefghijklmnopqrstuvwxyz0123456789"
        $MaxLength = 12

        $GeneratedPassword, $RemainingEntropy = ConsumeEntropy $GeneratedPassword $EntropyAsInt $SetOfCharacters $MaxLength

        It "returns generated password value" {
            $GeneratedPassword | Should -BeExactly "gsrwvjl3d0sn"
        }

        It "returns the remaining entropy" {
            $RemainingEntropy | Should -Be "21019920789038193790619410818194537836313158091882651458040"
        }
    }

    Context "GetOneCharPerRule" {
        [BigInt]$Entropy = "21019920789038193790619410818194537836313158091882651458040"
        
        It "get one char per rule without rules" {
            GetOneCharPerRule $Entropy @() `
            | Should -BeExactly "", "21019920789038193790619410818194537836313158091882651458040"
        }

        It "get one char per rule with several rules" {
            GetOneCharPerRule $Entropy @("lowercase", "digits") `
            | Should -BeExactly "a0", "80845849188608437656228503146902068601204454199548659454"
        }
    }

    Context "InsertStringPseudoRandomly" {
        It "add new characters" {
            [BigInt]$Entropy = "80845849188608437656228503146902068601204454199548659454"
            InsertStringPseudoRandomly "gsrwvjl3d0sn" $Entropy "a0" | Should -BeExactly "gsrwvjl03d0asn"
        }
    }

    Context "RenderPassword" {
        $PasswordProfile = @{
            site      = "example.org"
            login     = "contact@example.org"
            lowercase = $True
            digits    = $True
            length    = 14
            counter   = 1
        }
        $MasterPassword = "password"
        $Entropy = CalcEntropy $PasswordProfile $MasterPassword
        It "is correct" {
            RenderPassword $Entropy $PasswordProfile | Should -BeExactly "gsrwvjl03d0asn"
        }
    }
}

Describe 'Password' {
    Context "CalcEntropy" {
        It "Computes entropy as a lower case hexadecimal string" {
            $PasswordProfile = @{
                site      = "example.org"
                login     = "contact@example.org"
                counter   = 1
            }
            $MasterPassword = "password"

            CalcEntropy $PasswordProfile $MasterPassword | Should -BeExactly 'dc33d431bce2b01182c613382483ccdb0e2f66482cbba5e9d07dab34acc7eb1e'
        }
    }
    Context "Generate" {
        It 'with profile #1' {
            $PasswordProfile = @{
                site      = "example.org"
                login     = "contact@example.org"
                lowercase = $True
                uppercase = $True
                digits    = $True
                symbols   = $True
                length    = 16
                counter   = 1
            }
            $MasterPassword = "password"

            GeneratePassword $PasswordProfile $MasterPassword | Should -BeExactly "WHLpUL)e00[iHR+w"
        }

        It 'with profile #2' {
            $PasswordProfile = @{
                site      = "example.org"
                login     = "contact@example.org"
                lowercase = $True
                uppercase = $True
                digits    = $True
                symbols   = $false
                length    = 14
                counter   = 2
            }
            $MasterPassword = "password"
            
            GeneratePassword $PasswordProfile $MasterPassword | Should -BeExactly "MBAsB7b1Prt8Sl"
        }

        It 'with profile #3' {
            $PasswordProfile = @{
                site      = "example.org"
                login     = "contact@example.org"
                lowercase = $False
                uppercase = $False
                digits    = $True
                symbols   = $False
                length    = 16
                counter   = 1
            }
            $MasterPassword = "password"

            GeneratePassword $PasswordProfile $MasterPassword | Should -BeExactly "8742368585200667"
        }

        It 'with profile #4' {
            $PasswordProfile = @{
                site      = "example.org"
                login     = "contact@example.org"
                lowercase = $True
                uppercase = $True
                digits    = $False
                symbols   = $True
                length    = 16
                counter   = 1
            }
            $MasterPassword = "password"

            GeneratePassword $PasswordProfile $MasterPassword | Should -BeExactly "s>{F}RwkN/-fmM.X"
        }

        It 'with profile NRT 328' {
            $PasswordProfile = @{
                site      = "site"
                login     = "login"
                lowercase = $True
                uppercase = $True
                digits    = $True
                symbols   = $True
                length    = 16
                counter   = 10
            }
            $MasterPassword = "test"

            GeneratePassword $PasswordProfile $MasterPassword | Should -BeExactly "XFt0F*,r619:+}[."
        }
    }
}