# powershell script

$i = New-Object -ComObject iTunes.Application

# lyrics path
$lp = "C:\Users\rurbina\Dropbox\Lyrics"

# find songs with no lyrics
echo "Finding songs which require lyrics..."
$list = $i.Sources.ItemByName("Library").Playlists.ItemByName("Want Lyrics")
$delete_these = @()

#$songs = $i.LibraryPlaylist.Tracks | Where { -not $_.Podcast -and $_.KindasString -like "*audio*" -and $_.Lyrics.Length -eq 0 }

foreach ($song in $list.Tracks) {
    # if ( $song.Lyrics.Length -gt 0 ) {
    # 	echo "OK	$($song.Artist) - $($song.Album) - $($song.Name)"
    # 	$song.Delete()
    # 	continue;
    # }
    $filename = "$($lp)\$($song.Artist -replace ':', '_') - $($song.Album -replace ':', '_') - $($song.Name -replace ':', '_').txt".Replace('?','_')
    $file = gci $filename -ErrorAction silentlycontinue
    if ( $file -eq $null ) {
    	echo "NOT FOUND	$($song.Artist) - $($song.Album) - $($song.Name) [file $($filename)]" 
    }
    else {
	$lyrics = ( Get-Content $file | out-string )
	try {
	    $song.Lyrics = $lyrics
	    echo "ADDED	$($song.Artist) - $($song.Album) - $($song.Name)"
	    $delete_these += $song
	}
	catch {
	    echo "ERROR	$($song.Artist) - $($song.Album) - $($song.Name)"
	}
    }
}

foreach ($song in $delete_these) {
    $song.Delete()
}

# finish
$null = [System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$i)
[gc]::Collect()
Remove-Variable i



# SIG # Begin signature block
# MIIFrwYJKoZIhvcNAQcCoIIFoDCCBZwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUNbKJYrL/pwMwjr0RbF0gEtCF
# 1g6gggM0MIIDMDCCAhigAwIBAgIQKzWuCv8VVbJD0TDVEDuQUDANBgkqhkiG9w0B
# AQUFADAwMS4wLAYDVQQDDCVSaWNhcmRvIFVyYmluYSBQb3dlclNoZWxsIENlcnRp
# ZmljYXRlMB4XDTE2MDQyMTE1NDgzNVoXDTE3MDQyMTE2MDgzNVowMDEuMCwGA1UE
# AwwlUmljYXJkbyBVcmJpbmEgUG93ZXJTaGVsbCBDZXJ0aWZpY2F0ZTCCASIwDQYJ
# KoZIhvcNAQEBBQADggEPADCCAQoCggEBALVg3wKulyJ6n2mfPF+Bt4VZcubphDU+
# SMuiVjqjOmPx1oWNMyebvQc7HsJmnxbXcjtRWUqWONgn67M0XKvtZ5TP87sABHgE
# kugiR1AwY1u5hBQy3B8tOPsH9Umqe3ecunrdq2vKq/EML/34SmJY6oyGzxUuvLdd
# sdgV/q8R97F3f4Le7PVmqmAtgoxgblkqf8QD5AnCbGlyaUDYjdM7/vZqBkEoGMYS
# HyLXSoOwFQERbcSMPFs1Ics9mVyXJFR6fa0hCVEvs1qP8JhbNjB8K9dBog4S31E0
# 6cfvwOvHtiqoUZ1+a9Wxlo3yM+w1YJNg9+ekOAgDNZR2M7GzS/7KQC8CAwEAAaNG
# MEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQW
# BBQbge3ukP0UpNvCxDw2X+Z/iHHpmjANBgkqhkiG9w0BAQUFAAOCAQEAJnfMkPuh
# HryUOk8RpwMikJoTJwffPhOUaIwW4ZHMYkhnRDjatYqeIMHq3Jgt2MIIZ0RPFRfM
# cKspfXsjMLYi5PdQX5F6lQKV4GHFIPzJ1yCl+YP8A4g3bMc6R/Kmbe+/K2m/f5N1
# K4A3OBfuPgxv/CdsIi3NzZMYFvei+AlRmJAtr2vjGHxmb0pBzOyxMP1CDUA7GO0n
# LaG9i/dLwSqB4IATqr97hhCrurPylancew/3FM5lQs8kx9ANKv/xI7gZM9WgutFU
# vzL2tfsHwfMXCnYC7oBm0ZlOtvVxAvN66qYmEseoaxWajeDlaUmYVkiO4JwwfKDd
# gDLwkuNr35r2HTGCAeUwggHhAgEBMEQwMDEuMCwGA1UEAwwlUmljYXJkbyBVcmJp
# bmEgUG93ZXJTaGVsbCBDZXJ0aWZpY2F0ZQIQKzWuCv8VVbJD0TDVEDuQUDAJBgUr
# DgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMx
# DAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkq
# hkiG9w0BCQQxFgQUyBjo0RY2y2v6ysdioQdGiZ6FSSgwDQYJKoZIhvcNAQEBBQAE
# ggEABdwQheK04dkbBHq58ZQG0fNinhHuVKFnw1a/ITXOU1NJE4gkWT6qXNszPAjg
# hYo6bbHr3VOtC54p8Y4BtNlLlshc90PFiFIiyq7a45rQGObYlxQ3ps95u7pf2umd
# kpEoeVyFtYI0TwuddmFyDOi3SuXwbFxVSqJahwV/7cjhY4IvzTdWOKLb4ZUdpQOj
# j5GNCypgBWglffnJ3hiWUVDdlPqzPE9t+MCu769UBy9Cn+aXY0IKVUXat7Ei5vYb
# BS3foN/typMiu8CTi2k2X4DXeqbNuT2IzHFonf1+0CG0WO/7Erur/lOi1mj1qW2P
# 8b0x04iacYit/FxLgJryCd7slQ==
# SIG # End signature block
