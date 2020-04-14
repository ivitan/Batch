@echo off 
echo ========创建一个数组========
set list=1 2 3 4 
(for %%a in (%list%) do ( 
   echo %%a 
))

echo ==========================

set a[0]=1 
echo %a[0]%

echo ===========访问数组===============
set a[0]=1 
set a[1]=2 
set a[2]=3 
echo The first element of the array is %a[0]% 
echo The second element of the array is %a[1]% 
echo The third element of the array is %a[2]%

echo ===========修改数组==================
set a[0]=1 
set a[1]=2 
set a[2]=3 
Rem Adding an element at the end of an array 
Set a[3]=4 
echo The last element of the array is %a[3]%

echo ======================================
set a[0]=1 
set a[1]=2 
set a[2]=3 
Rem Setting the new value for the second element of the array 
Set a[1]=5 
echo The new value of the second element of the array is %a[1]%
pause