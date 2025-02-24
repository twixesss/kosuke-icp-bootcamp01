import Result "mo:base/Result";
import Text "mo:base/Text";
import Map "mo:map/Map";
// import Debug "mo:base/Debug";
import { phash; nhash } "mo:map/Map";
import Nat "mo:base/Nat";
// import Array "mo:base/Array";
// import Vector "mo:vector";
import List "mo:base/List";

actor {
    stable var autoIndex = 0;
    let userIdMap = Map.new<Principal, Nat>();
    let userProfileMap = Map.new<Nat, Text>();
    let userResultsMap = Map.new<Nat, [Text]>();


    // public query ({ caller }) func getUserProfile() : async Result.Result<{ id : Nat; name : Text }, Text> {
    //     return #ok({ id = 123; name = "test" });
    // };

    public query ({ caller }) func getUserProfile() : async Result.Result<{ id : Nat; name : Text }, Text> {
        // Retrieve the user ID associated with the caller's Principal
        let maybeId = Map.get(userIdMap, phash, caller);
        switch (maybeId) {
            case (?id) {
                // Retrieve the profile name for the found user ID
                let maybeName = Map.get(userProfileMap, nhash, id);
                switch (maybeName) {
                    case (?name) {
                        return #ok({ id = id; name = name });
                    };
                    case (_) {
                        return #err("Profile not found for user id");
                    };
                }
            };
            case (_) {
                return #err("User not registered");
            };
        }
    };


    public shared ({ caller }) func setUserProfile(name : Text) : async Result.Result<{ id : Nat; name : Text }, Text> {
        // check if user already exists
        switch (Map.get (userIdMap, phash, caller)){
            case (?_) {};
            case (_) { 
                // set user id
                Map.set (userIdMap, phash, caller, autoIndex);
                // increment for the next user
                autoIndex += 1;
            };
        };
        
        // set profile name
        let foundId = switch (Map.get(userIdMap, phash, caller)){
            case (?found) found;
            case (_) { return #err("User not found"); };
        };
        
        Map.set(userProfileMap, nhash, foundId, name);

        return #ok({ id = foundId; name = name});
    };

    // public shared ({ caller }) func addUserResult(result : Text) : async Result.Result<{ id : Nat; results : [Text] }, Text> {
    //     return #ok({ id = 123; results = ["fake result"] });
    // };

    public shared ({ caller }) func addUserResult(result : Text) : async Result.Result<{ id : Nat; results : [Text] }, Text> {
        // get user id
        let maybeId = Map.get(userIdMap, phash, caller);
        switch (maybeId) {
            case (?id) {
                // get current results
                let currentResults = switch (Map.get(userResultsMap, nhash, id)) {
                    case (?results) results;
                    case (_) ([] : [Text])
                };
                // convert current results to list
                let currentList = List.fromArray(currentResults);
                // convert new result to list
                let newList = List.fromArray([result]);
                // combine the two lists
                let updatedList = List.append(currentList, newList);
                // convert the combined list back to an array
                let updatedResults = List.toArray(updatedList);
                // update the user results
                Map.set(userResultsMap, nhash, id, updatedResults);
                return #ok({ id = id; results = updatedResults });
            };
            case (_) {
                return #err("User not registered");
            };
        }
    };



    // public query ({ caller }) func getUserResults() : async Result.Result<{ id : Nat; results : [Text] }, Text> {
    //     return #ok({ id = 123; results = ["fake result"] });
    // };

    public query ({ caller }) func getUserResults() : async Result.Result<{ id : Nat; results : [Text] }, Text> {
        // Retrieve the user id associated with the caller's Principal.
        let maybeId = Map.get(userIdMap, phash, caller);
        switch (maybeId) {
            case (?id) {
                // Retrieve the stored results for the user, defaulting to an empty array if none exist.
                let maybeResults = Map.get(userResultsMap, nhash, id);
                switch (maybeResults) {
                    case (?results) {
                        return #ok({ id = id; results = results });
                    };
                    case (_) {
                        return #ok({ id = id; results = ([] : [Text]) });
                    };
                }
            };
            case (_) {
                return #err("User not registered");
            };
        }
    };


};
