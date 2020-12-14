This contract features an online market place with an owner - the deployer,  a maximum of three admins can be added and granted permission to add storeowners. 
The need for administrators is to shield down the power of the owner to remove to an extent elements of centralization.
Admin are granted permissions and can be revoked by the owner. 
Admins can add storeowners and same time have the power to deactivate.
Approveed StoreOwners are able to create a storefront and add items to shelves. There are couples of functions available to the storeOwners with regards to store and item (s) created.

Anyone with an ethereum account can buy from Dmarket using the native cryptocurrency - DMT

Dmarket does not feature a third party library but uses an extended contract that passes token functionality down to it. Also, to avoid a common attack known to be "integer overflow and underflow", Dmarket implemented a logic that checks for underflow or overflow before a function call is executed.

I have also used a few modifiers to avoid known backdoors such as bad actors trying to highjack ownership, denial of service attack, token theft(account will be frozen) plus a few others.