import Principal "mo:base/Principal";

module {
    public type TokenAddress = Principal;
    public type TokenId = Nat;
    public type Order = {#less; #equal; #greater};
    public type Properties = [(Text, Text)];
    public type CollectionMetadata = {
        name: Text;
        logo: Text;
        symbol: Text;
        tags: [Text];
        custodians: [Principal];
        created_at: Nat64;
        upgraded_at: Nat64;
        max_items: Nat64;
    };

    public type Stats = {
        total_transactions: Nat;
        total_supply: Nat;
        cycles: Nat;
        total_unique_holders: Nat;
    };

    public type GenericValue = {
        #boolContent: Bool;
        #textContent: Text;
        #blobContent: [Nat8];
        #principal: Principal;
        #nat8Content: Nat8;
        #nat16Content: Nat16;
        #nat32Content: Nat32;
        #nat64Content: Nat64;
        #natContent: Nat;
        #int8Content: Int8;
        #int16Content: Int16;
        #int32Content: Int32;
        #int64Content: Int64;
        #intContent: Int;
        #floatContent: Float;
        #nestedContent: [(Text, GenericValue)];
    };
    
    public type TokenMetadata = {
        token_identifier: Nat;
        owner: ?Principal;
        operator_: ?Principal;
        is_burned: Bool;
        properties: Properties;
        minted_at: Int;
        minted_by: Principal;
        transferred_at: ?Int;
        transferred_by: ?Principal;
        approved_at: ?Nat64;
        approved_by: ?Principal;
        burned_at: ?Nat64;
        burned_by: ?Principal;
        collection: ?CollectionMetadata;
    };

    public type TxEvent = {
        time: Nat64;
        caller: Principal;
        operation: Text;
        details: [(Text, GenericValue)];
    };

    
    public type SupportedInterface = {
        #approval;
        #mint;
        #burn;
        #transactionHistory;
    };
    
    public type NftError = {
        #unauthorizedOwner;
        #unauthorizedOperator;
        #ownerNotFound;
        #operatorNotFound;
        #tokenNotFound;
        #existedNFT;
        #selfApprove;
        #selfTransfer;
        #txNotFound;
        #other;
    };

    public type TxReceipt = {
        #Ok: Nat;
        #Err: {
            #InsufficientAllowance;
            #InsufficientBalance;
            #ErrorOperationStyle;
            #Unauthorized;
            #LedgerTrap;
            #ErrorTo;
            #Other: Text;
            #BlockUsed;
            #AmountTooSmall;
            #WrongCode;
            #NotEnoughUnlockedTokens;
            #IncompatibleSpecialTransferCombination;
        };
    };
}