


# Function to go look for DNS entries and see if we need to actually do anything
Function Get-ObjectDNS ($compObject) {
    

}

## Remove AD DNS entry - forward and [DscResource()]
Function Get-RemoveADDNSEntry ($computerName) {

    $dnsZones = Get-DnsServerZone | ? { $_.IsReverseLookupZone -eq $false } | ? { $_.ZoneName -ne "TrustAnchors" -and $_.ZoneName -notlike "_msdcs*" }

    

}


#>Function to Start all this madness, go get the server object
Function Get-RemoveADComputer ($computerName) {
    
    ## Go get objects with the right name from the domain
    $computerObject = Get-AdComputer -filter { Name -like $computerName }

    ## Count how many we got, we ONLY want to work on one
    $count = (($computerObject | Measure-Object).Count)

    ## Test we only got one, otherwise exit and complain
    if ( $count -eq 1 ) {

        Write-Host "Working on:" $computerObject.Name

        ## Safety first -disable the account, we can use this as an extra safety later and "only delete 1 account that's disabled"
        $computerObject | Disable-ADAccount -erroraction SilentlyContinue
       
        # If you uncomment the following two lines, the script will hold here with a message on screen so you can check if it disabled the right arround
        ##Write-Host "Pause before deletion"
        ##pause

        ## Right, I have no idea why it's necessary to pull this again, but it doesn't see the disable unless we do
        $computerObject = Get-AdComputer -filter { Name -like $computerName }

        ## Final check, disabled and there's only 1 of them?
        if (!($computerObject.Enabled) -and ((($computerObject | Measure-Object).Count) -eq 1) ){
            
            ## Deletion time:
            $computerObject | Remove-ADComputer -Confirm:$false
            
        } else {
            
            Write-Host "Error - Final check showed accout wasn't disabled or we got more than one object back"
        }


    } else {

        Write-Host "Error, expected 1 object, got $count"

    }

}