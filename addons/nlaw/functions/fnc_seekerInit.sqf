// Framework seeker onFired: initialize only the local proximity-fuze state.
params ["_firedEH", "_launchParams", "", "", "_states"];
private _position = getPosASL (_firedEH select 6);
private _state = _states select 1;
{ _state set [_forEachIndex, _x]; } forEach [
    _position, vectorMagnitude velocity (_firedEH select 6), _position,
    (_launchParams select 3) == "ace_nlaw_overflyTopAttack", false, -1
];
