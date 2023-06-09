// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module nonfungible::whitelist {

    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
	use sui::vec_map::{Self, VecMap};

    const ERROR_ADDRESS_IN_WHITELIST: u64 = 0;
    const ERROR_ADDRESS_NOT_IN_WHITELIST: u64 = 1;
	const ERROR_LENGTH_IS_NOT_EQUAL: u64 = 2;

    struct AdminCap has key { id: UID }


    struct WhitelistStorage has key { 
        id: UID,
        accounts: VecMap<address, bool>
    }

    fun init(ctx: &mut TxContext){
        let sender = tx_context::sender(ctx);
        transfer::transfer(AdminCap {
            id: object::new(ctx)
        }, sender);

        transfer::share_object(
            WhitelistStorage {
                id: object::new(ctx),
                accounts: vec_map::empty()
            }
        );    
    }

	public entry fun add_whitelist(
        _: &AdminCap, 
		storage: &mut WhitelistStorage, 
        wallet: address,
        _ctx: &mut TxContext
    ) 
    {
        assert!(
            !vec_map::contains(&storage.accounts, &wallet), ERROR_ADDRESS_IN_WHITELIST
        );
        vec_map::insert(&mut storage.accounts, wallet, true);
    }


    public entry fun hard_remove_whitelist(
       _: &AdminCap, 
       storage: &mut WhitelistStorage, 
       wallet: address,
       _ctx: &mut TxContext, 
    )
    {
        // Check if the wallet address is already in the whitelist
        assert!(
            vec_map::contains(&storage.accounts, &wallet), ERROR_ADDRESS_NOT_IN_WHITELIST
        );
        vec_map::remove(&mut storage.accounts, &wallet);
    }

    public entry fun soft_remove_whitelist(
       _: &AdminCap, 
       storage: &mut WhitelistStorage, 
       wallet: address,
       _ctx: &mut TxContext, 
    )
    {
        // Check if the wallet address is already in the whitelist
        assert!(
            vec_map::contains(&storage.accounts, &wallet), ERROR_ADDRESS_NOT_IN_WHITELIST
        );
        let whitelist_status = vec_map::get_mut(&mut storage.accounts, &wallet);
        *whitelist_status = false;
    }

    public fun is_whitelist(
        storage: &WhitelistStorage, 
        wallet: address,
        _ctx: &mut TxContext, 
    ): bool
    {
        let result = if(vec_map::contains(&storage.accounts, &wallet)){
            *vec_map::get(&storage.accounts, &wallet)
        } else {
            false
        };
        result
    }
}
