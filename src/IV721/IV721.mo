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

actor class DRC721(_name : Text, _symbol : Text, _tags: Text, _metadata : T.Properties, _dynamic : Bool, _equips: Bool) {
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