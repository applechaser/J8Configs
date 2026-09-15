/* ACE 3.21.2 attack profile onFired contract.
 * Freeze launcher attitude and a least-squares angular rate at launch.
 * This component owns the preprogrammed trajectory, not the flight controller.
 */
params ["_firedEH", "_launchParams", "", "", "_stateParams"];
_firedEH params ["_shooter", "_weapon", "", "", "", "", "_projectile"];
_launchParams params ["", "_targetLaunchParams", "", "_mode"];
_stateParams params ["", "", "_profileState"];

private _now = missionNamespace getVariable ["J8_nlaw_simTime", 0];
private _los = _shooter weaponDirection _weapon;
if (vectorMagnitude _los < 0.5) then { _los = vectorDir _projectile; };
(_los call CBA_fnc_vect2Polar) params ["", "_yaw", "_pitch"];
private _yawChange = 0;
private _pitchChange = 0;
private _history = _shooter getVariable ["J8_nlaw_history", ["", []]];
_history params ["_sampleWeapon", "_samples"];
private _tracking = !isPlayer _shooter || {
    _shooter == (missionNamespace getVariable ["ACE_player", objNull])
    && {missionNamespace getVariable ["ace_nlaw_isLockKeyDown", false]}
};
if (_tracking && {_sampleWeapon == _weapon} && {count _samples >= 2}) then {
    private _firstTime = (_samples select 0) select 0;
    private _lastTime = (_samples select - 1) select 0;
    // Incomplete or stale tracking gives zero lead, never target-derived lead.
    if (_lastTime - _firstTime >= 0.75 && {_now - _lastTime <= 0.3}) then {
        private _n = count _samples;
        private _meanT = 0;
        private _meanYaw = 0;
        private _meanPitch = 0;
        {
            _meanT = _meanT + ((_x select 0) - _firstTime);
            _meanYaw = _meanYaw + (_x select 1);
            _meanPitch = _meanPitch + (_x select 2);
        } forEach _samples;
        _meanT = _meanT / _n;
        _meanYaw = _meanYaw / _n;
        _meanPitch = _meanPitch / _n;
        private _denominator = 0;
        private _yawNumerator = 0;
        private _pitchNumerator = 0;
        {
            private _dt = (_x select 0) - _firstTime - _meanT;
            _denominator = _denominator + _dt * _dt;
            _yawNumerator = _yawNumerator + _dt * ((_x select 1) - _meanYaw);
            _pitchNumerator = _pitchNumerator + _dt * ((_x select 2) - _meanPitch);
        } forEach _samples;
        if (_denominator > 0.000001) then {
            _yawChange = _yawNumerator / _denominator;
            _pitchChange = _pitchNumerator / _denominator;
        };
    };
};

// Bound bad tracking input; degrees/second.
_yawChange = -10 max (_yawChange min 10);
_pitchChange = -10 max (_pitchChange min 10);
private _launchPos = getPosASL _projectile;
// Discard framework target metadata before any flight update can use it.
_targetLaunchParams set [0, objNull];
_targetLaunchParams set [1, [0, 0, 0]];
_targetLaunchParams set [2, _launchPos];
_stateParams set [3, [false, [0, 0, 0]]];

// Only the attack profile reads this state during flight.
{ _profileState set [_forEachIndex, _x]; } forEach [
    _now, _launchPos, _yaw, _pitch, _yawChange, _pitchChange,
    _mode == "ace_nlaw_overflyTopAttack"
];
