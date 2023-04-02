/// Module of the `UrlDomain`
///
/// Used to associate a URL with `Collection` or `Nft`.add
///
/// Interoperability functions are delegated to the `display_ext` module.
module nft_protocol::url {
    use std::ascii::String;
    use sui::url::{Self, Url};
    use sui::dynamic_field as df;
    use sui::object::UID;

    use nft_protocol::utils::{
        assert_with_witness, UidType, marker, Marker
    };

    /// No field object `Url` defined as a dynamic field with key `Key`.
    const EUNDEFINED_URL_FIELD: u64 = 1;

    /// Field object `Url` already defined as dynamic field with key `Key`.
    const EURL_FIELD_ALREADY_EXISTS: u64 = 2;

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}


    // === Insert with module specific Witness ===


    /// Adds `Tags` as a dynamic field with key `TagsKey`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    public fun add_url<W: drop, T: key, Key: copy + store + drop>(
        _witness: W,
        object_uid: &mut UID,
        object_type: UidType<T>,
        url: String,
    ) {
        assert_has_not_url<Key>(object_uid);
        assert_with_witness<W, T>(object_uid, object_type);

        let url = url::new_unsafe(url);

        df::add(object_uid, marker<Key>(), url);
    }

    // === Field Borrow Functions ===


    /// Borrows immutably the `Url` field with the key `Key`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `Marker<Key>` does not exist.
    public fun borrow_url<Key: copy + store + drop>(
        object_uid: &UID,
    ): &Url {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_url<Key>(object_uid);
        df::borrow(object_uid, marker<Key>())
    }

    /// Borrows Mutably the `Url` field with the key `Key`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `Marker<Key>` does not exist.
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    public fun borrow_tags_mut<W: drop, T: key, Key: copy + store + drop>(
        _witness: W,
        object_uid: &mut UID,
        object_type: UidType<T>
    ): &mut Url {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_url<Key>(object_uid);
        assert_with_witness<W, T>(object_uid, object_type);

        let tags = df::borrow_mut<Marker<Key>, Url>(
            object_uid,
            marker<Key>()
        );

        tags
    }

    // === Writer Functions ===


    /// Sets URL of for field with key `Key`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `AttributesKey` does not exist.
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    public fun set_url<W: drop, T: key, Key: store + copy + drop>(
        _witness: W,
        object_uid: &mut UID,
        object_type: UidType<T>,
        new_url: String,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_url<Key>(object_uid);
        assert_with_witness<W, T>(object_uid, object_type);

        let url = borrow_mut_internal<Key>(object_uid);

        *url = url::new_unsafe(new_url);
    }


    // === Private Functions ===


    /// Borrows Mutably the `Tags` field with key `Key`.
    ///
    /// For internal use only.
    fun borrow_mut_internal<Key: store + copy + drop>(
        object_uid: &mut UID,
    ): &mut Url {
        df::borrow_mut<Marker<Key>, Url>(
            object_uid,
            marker<Key>()
        )
    }


    // === Assertions ===


    /// Checks that a given NFT has a dynamic field with `Marker<Tags>`
    public fun has_url<Key: copy + store + drop>(
        object_uid: &UID,
    ): bool {
        df::exists_(object_uid, marker<Key>())
    }

    public fun assert_has_url<Key: copy + store + drop>(object_uid: &UID) {
        assert!(has_url<Key>(object_uid), EUNDEFINED_URL_FIELD);
    }

    public fun assert_has_not_url<Key: copy + store + drop>(object_uid: &UID) {
        assert!(!has_url<Key>(object_uid), EURL_FIELD_ALREADY_EXISTS);
    }
}
