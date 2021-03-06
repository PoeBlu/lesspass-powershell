> ##### ✋ Psst! Create [issue on the lesspass/lesspass](https://github.com/lesspass/lesspass/issues/new) repo as I will [merge](https://github.com/lesspass/lesspass/issues/407) into it.
> 
# Lesspass-powershell

> LessPass open source password manager (powershell implementation)

## Install

```powershell
PS> Install-Module -Name Lesspass
```

## Usage

```powershell
PS> Get-LessPass "site" "login" "masterpassword"
```

**Help**

```powershell
PS> Get-LessPass -?
```

**Syntax**

```powershell
Get-LessPass
    -site <String>
    -login <String>
    -master_password <String>

    [-lowercase]
    [-uppercase]
    [-digits]
    [-symbols]
    [-noLowercase]
    [-noUppercase]
    [-noDigits]
    [-noSymbols]
    [[-length] <Object>]
    [[-counter] <Object>]

    [-version]
    [<CommonParameters>]
```

## Test

```make
make test
```