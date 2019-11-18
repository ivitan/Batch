Get-AppXPackage *Office* -allUsers | Remove-AppXPackage
Get-AppXPackage *Office* -PackageTypeFilter bundle -allUsers | Remove-AppXPackage -allUsers