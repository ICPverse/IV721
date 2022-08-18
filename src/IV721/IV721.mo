import Error "mo:base/Error";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import T "iv721_types";
import Debug "mo:base/Debug";
import Time "mo:base/Time";

actor class DRC721(_name : Text, _symbol : Text, _tags: [Text],  _dynamic : Bool, _equips: Bool) {
    private stable var tokenPk : Nat = 0;

    private stable var tokenURIEntries : [(T.TokenId, Text)] = [];
    private stable var tokenDynamicURIEntries : [(T.TokenId, Text)] = [];
    private stable var ownersEntries : [(T.TokenId, Principal)] = [];
    private stable var balancesEntries : [(Principal, Nat)] = [];
    private stable var tokenApprovalsEntries : [(T.TokenId, Principal)] = [];
    private stable var operatorApprovalsEntries : [(Principal, [Principal])] = [];
    private stable var propertiesEntries : [(T.TokenId, T.Properties)] = [];
    private stable var propertyFrequencyEntries : [(Text, Nat)] = [];
    private stable var equippedEntries: [(T.TokenId, Bool)] = [];
    private stable var evolvedEntries : [(T.TokenId, Bool)] = [];

    private let tokenURIs : HashMap.HashMap<T.TokenId, Text> = HashMap.fromIter<T.TokenId, Text>(tokenURIEntries.vals(), 10, Nat.equal, Hash.hash);
    private let tokenDynamicURIs : HashMap.HashMap<T.TokenId, Text> = HashMap.fromIter<T.TokenId, Text>(tokenDynamicURIEntries.vals(), 10, Nat.equal, Hash.hash);
    private let owners : HashMap.HashMap<T.TokenId, Principal> = HashMap.fromIter<T.TokenId, Principal>(ownersEntries.vals(), 10, Nat.equal, Hash.hash);
    private let balances : HashMap.HashMap<Principal, Nat> = HashMap.fromIter<Principal, Nat>(balancesEntries.vals(), 10, Principal.equal, Principal.hash);
    private let tokenApprovals : HashMap.HashMap<T.TokenId, Principal> = HashMap.fromIter<T.TokenId, Principal>(tokenApprovalsEntries.vals(), 10, Nat.equal, Hash.hash);
    private let operatorApprovals : HashMap.HashMap<Principal, [Principal]> = HashMap.fromIter<Principal, [Principal]>(operatorApprovalsEntries.vals(), 10, Principal.equal, Principal.hash);
    private let properties : HashMap.HashMap<T.TokenId, T.Properties> = HashMap.fromIter<T.TokenId, T.Properties>(propertiesEntries.vals(), 10, Nat.equal, Hash.hash);
    private let propertyFrequencies : HashMap.HashMap<Text, Nat> = HashMap.fromIter<Text, Nat>(propertyFrequencyEntries.vals(), 10, Text.equal, Text.hash);
    private let equipped : HashMap.HashMap<T.TokenId, Bool> = HashMap.fromIter<T.TokenId, Bool>(equippedEntries.vals(), 10, Nat.equal, Hash.hash);
    private let evolved : HashMap.HashMap<T.TokenId, Bool> = HashMap.fromIter<T.TokenId, Bool>(evolvedEntries.vals(), 10, Nat.equal, Hash.hash);



    public shared func getBalance(of : Principal) : async ?Nat {
        return balances.get(of);
    };

    public shared func getOwner(tokenId : T.TokenId) : async ?Principal {
        return _ownerOf(tokenId);
    };

    public shared query func getTokenURI(tokenId : T.TokenId) : async ?Text {
        return _tokenURI(tokenId);
    };

    public shared query func getName() : async Text {
        return _name;
    };

    public shared query func getSymbol() : async Text {
        return _symbol;
    };

    public shared query func getTags() : async [Text] {
        return _tags;
    };

    public shared query func isDynamic() : async Bool {
        return _dynamic;
    };

    public shared query func isEquippable() : async Bool {
        return _equips;
    };

    public shared func isApprovedForAll(owner : Principal, opperator : Principal) : async Bool {
        return _isApprovedForAll(owner, opperator);
    };

    public shared(msg) func approve(to : Principal, tokenId : T.TokenId) : async () {
        switch(_ownerOf(tokenId)) {
            case (?owner) {
                 assert to != owner;
                 assert msg.caller == owner or _isApprovedForAll(owner, msg.caller);
                 _approve(to, tokenId);
            };
            case (null) {
                throw Error.reject("No owner for token")
            };
        }
    };

    public shared func getApproved(tokenId : Nat) : async Principal {
        switch(_getApproved(tokenId)) {
            case (?v) { return v };
            case null { throw Error.reject("None approved")}
        }
    };

    public shared(msg) func setApprovalForAll(op : Principal, isApproved : Bool) : () {
        assert msg.caller != op;

        switch (isApproved) {
            case true {
                switch (operatorApprovals.get(msg.caller)) {
                    case (?opList) {
                        var array = Array.filter<Principal>(opList,func (p) { p != op });
                        array := Array.append<Principal>(array, [op]);
                        operatorApprovals.put(msg.caller, array);
                    };
                    case null {
                        operatorApprovals.put(msg.caller, [op]);
                    };
                };
            };
            case false {
                switch (operatorApprovals.get(msg.caller)) {
                    case (?opList) {
                        let array = Array.filter<Principal>(opList, func(p) { p != op });
                        operatorApprovals.put(msg.caller, array);
                    };
                    case null {
                        operatorApprovals.put(msg.caller, []);
                    };
                };
            };
        };
        
    };

    public shared(msg) func transferFrom(from : Principal, to : Principal, tokenId : Nat) : () {
        assert _isApprovedOrOwner(msg.caller, tokenId);

        _transfer(from, to, tokenId);
    };

    public shared(msg) func mint(uri : Text) : async Nat {
        tokenPk += 1;
        _mint(msg.caller, tokenPk, uri);
        return tokenPk;
    };


    // Internal

    private func _ownerOf(tokenId : T.TokenId) : ?Principal {
        return owners.get(tokenId);
    };

    private func _tokenURI(tokenId : T.TokenId) : ?Text {
        return tokenURIs.get(tokenId);
    };

    private func _isApprovedForAll(owner : Principal, opperator : Principal) : Bool {
        switch (operatorApprovals.get(owner)) {
            case(?whiteList) {
                for (allow in whiteList.vals()) {
                    if (allow == opperator) {
                        return true;
                    };
                };
            };
            case null {return false;};
        };
        return false;
    };

    private func _approve(to : Principal, tokenId : Nat) : () {
        tokenApprovals.put(tokenId, to);
    };

    private func _removeApprove(tokenId : Nat) : () {
        let _ = tokenApprovals.remove(tokenId);
    };

    private func _exists(tokenId : Nat) : Bool {
        return Option.isSome(owners.get(tokenId));
    };

    private func _getApproved(tokenId : Nat) : ?Principal {
        assert _exists(tokenId) == true;
        switch(tokenApprovals.get(tokenId)) {
            case (?v) { return ?v };
            case null {
                return null;
            };
        }
    };

    private func _hasApprovedAndSame(tokenId : Nat, spender : Principal) : Bool {
        switch(_getApproved(tokenId)) {
            case (?v) {
                return v == spender;
            };
            case null { return false}
        }
    };

    private func _isApprovedOrOwner(spender : Principal, tokenId : Nat) : Bool {
        assert _exists(tokenId);
        let ownerOpt = _ownerOf(tokenId);
        var owner = Principal.fromText("2vxsx-fae");
        switch ownerOpt{
            case null{
                return false;
            };
            case (?principal){
                owner := principal;
            };
        };
        return spender == owner or _hasApprovedAndSame(tokenId, spender) or _isApprovedForAll(owner, spender);
    };

    private func _transfer(from : Principal, to : Principal, tokenId : Nat) : () {
        assert _exists(tokenId);
        let ownerOpt = _ownerOf(tokenId);
        var owner = Principal.fromText("2vxsx-fae");
        switch ownerOpt{
            case null{};
            case (?principal){
                owner := principal;
            };
        };
        assert owner == from;

        // Bug in HashMap https://github.com/dfinity/motoko-base/pull/253/files
        // this will throw unless you patch your file
        _removeApprove(tokenId);

        _decrementBalance(from);
        _incrementBalance(to);
        owners.put(tokenId, to);
    };

    private func _incrementBalance(address : Principal) {
        switch (balances.get(address)) {
            case (?v) {
                balances.put(address, v + 1);
            };
            case null {
                balances.put(address, 1);
            }
        }
    };

    private func _decrementBalance(address : Principal) {
        switch (balances.get(address)) {
            case (?v) {
                balances.put(address, v - 1);
            };
            case null {
                balances.put(address, 0);
            }
        }
    };

    private func _mint(to : Principal, tokenId : Nat, uri : Text) : () {
        assert not _exists(tokenId);

        _incrementBalance(to);
        owners.put(tokenId, to);
        tokenURIs.put(tokenId,uri)
    };

    private func _burn(tokenId : Nat) : () {
        assert _exists(tokenId) == true;
        let ownerOpt = _ownerOf(tokenId);
        var owner = Principal.fromText("2vxsx-fae");
        switch ownerOpt{
            case null{};
            case (?principal){
                owner := principal;
            };
        };
        

        _removeApprove(tokenId);
        _decrementBalance(owner);

        ignore owners.remove(tokenId);
    };

    system func preupgrade() {
        tokenURIEntries := Iter.toArray(tokenURIs.entries());
        tokenDynamicURIEntries := Iter.toArray(tokenDynamicURIs.entries());
        ownersEntries := Iter.toArray(owners.entries());
        balancesEntries := Iter.toArray(balances.entries());
        propertiesEntries := Iter.toArray(properties.entries());
        propertyFrequencyEntries := Iter.toArray(propertyFrequencies.entries());
        tokenApprovalsEntries := Iter.toArray(tokenApprovals.entries());
        operatorApprovalsEntries := Iter.toArray(operatorApprovals.entries());
        evolvedEntries := Iter.toArray(evolved.entries());
        equippedEntries := Iter.toArray(equipped.entries());
    };

    system func postupgrade() {
        tokenURIEntries := [];
        tokenDynamicURIEntries := [];
        ownersEntries := [];
        balancesEntries := [];
        propertiesEntries := [];
        propertyFrequencyEntries := [];
        tokenApprovalsEntries := [];
        operatorApprovalsEntries := [];
        evolvedEntries := [];
        equippedEntries := [];
    };

};