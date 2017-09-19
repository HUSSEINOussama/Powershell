# Exchange 2013 Server Health Check
# Cameron Murray (cam@camm.id.au)
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

Param(
  [string]$HealthSet
)

$status = 0

add-pssnapin Microsoft.Exchange.Management.PowerShell.SnapIn


# Get health checks for role
$HealthSetResult = (get-serverhealth | Where-Object {$_.HealthSetName -eq $HealthSet})

# Filter by Degraded state
$DegradedHealthChecks = $HealthSetResult | Where-Object {($_.AlertValue -eq "Degraded") -or ($_.AlertValue -eq "Unhealthy")}

if($DegradedHealthChecks.Length -gt 0) {

    # Atleast one health check is degraded or unhealthy

    $status=2

    foreach($healthCheck in $DegradedHealthChecks) {
        $desc = "$desc $($DegradedHealthChecks.Name) ,"
    }

    $desc = "$desc checks in Degraded or Unhealthy State"
}

if ($status -eq "2") {
	Write-Host "CRITICAL: $desc"
} elseif ($status -eq "0") {
	Write-Host "OK: $HealthSet - $($HealthSetResult.Length) checks are OK"
} 

exit $status