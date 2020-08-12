function Get-SG {
    [cmdletBinding()]

    param 
    (
        [string]$sgdet
    )

    Try {
        switch -Regex ($sgdet) {
            
            '^(?!sg-)[a-zA-Z]' { $sgfilter = @{name = 'tag:Name'; values = "*" + "$sgdet" + "*" }
                $SecurityGroupDet = get-ec2securitygroup -filter $sgfilter
                $obj =[PSCustomObject]@{id = $SecurityGroupDet.GroupID
                    Description             = $SecurityGroupDet.Description
                    GroupName               = $SecurityGroupDet.GroupName
                    IPIngress               = $SecurityGroupDet.IPPermissions
                    IPEgress                = $SecurityGroupDet.IPPermissionsEgress
                    Name                    = $SecurityGroupDet.tag | Where-Object { $_.key -eq 'Name' } | select-object -ExpandProperty value
                    Env                     = $SecurityGroupDet.tag | Where-Object { $_.key -eq 'Environment' } | select-object -ExpandProperty value 
                    VpcId                   = $SecurityGroupDet.vpcid
                }
            }
            '^sg-*' {
                $SecurityGroupDet = get-ec2securitygroup $sgdet
                $obj =[PSCustomObject]@{id = $SecurityGroupDet.GroupID
                    Description             = $SecurityGroupDet.Description
                    GroupName               = $SecurityGroupDet.GroupName
                    IPIngress               = $SecurityGroupDet.IPPermissions
                    IPEgress                = $SecurityGroupDet.IPPermissionsEgress
                    Name                    = $SecurityGroupDet.tag | Where-Object { $_.key -eq 'Name' } | select-object -ExpandProperty value 
                    Env                     = $SecurityGroupDet.tag | Where-Object { $_.key -eq 'Environment' } | select-object -ExpandProperty value 
                    VpcId                   = $SecurityGroupDet.vpcid
                }
            }
            
        }
    }
    Catch { Write-Output "Unknown Input.  Please enter a Host name, an Instnace name or an IP address - wildcards (*) are assumed.  If you entered the correct name the instance may not exist" }

    #write-output $obj
    if ($obj.id.count -lt 2) {
    
        write-output $obj
    }
    else {
        for ($i = 0; $i -lt $obj.id.Count; $i++) {
            write-output "$($obj.id[$i]) `t $($obj.GroupName[$i]) `t $($obj.Name[$i]) `t $($obj.Env[$i]) `t $($obj.VpcId[$i]) `t $($obj.Description[$i])" 
        }
    }
}
