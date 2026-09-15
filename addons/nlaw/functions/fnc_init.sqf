/* Sample the launcher's orientation only. No target acquisition or ranging.
 * Player: record while holding ACE's existing Track Target key.
 * AI: record while the local unit has an NLAW raised/selected.
 * All machines run this, including dedicated servers and headless clients.
 */
if (!isNil "J8_nlaw_samplePFH") exitWith {};
J8_nlaw_samplePFH = [{
    params ["_samplingState"];
    if (isGamePaused || {accTime <= 0}) exitWith {};
    // Pre-launch tracking uses engine simulation time; flight uses ACE's timestep.
    private _now = time;
    if (_now < (_samplingState select 0)) exitWith {};
    _samplingState set [0, _now + 0.05];
    {
        private _unit = _x;
        if (local _unit) then {
            private _weapon = currentWeapon _unit;
            private _tracking = alive _unit
                && {getNumber (configFile >> "CfgWeapons" >> _weapon >> "ace_nlaw_enabled") == 1}
                && {!weaponLowered _unit}
                && {!isPlayer _unit || {
                    _unit == (missionNamespace getVariable ["ACE_player", objNull])
                    && {missionNamespace getVariable ["ace_nlaw_isLockKeyDown", false]}
                }};
            if (!_tracking) then {
                if (!isNil {_unit getVariable "J8_nlaw_history"}) then {
                    _unit setVariable ["J8_nlaw_history", nil];
                };
            } else {
                private _history = _unit getVariable ["J8_nlaw_history", ["", []]];
                _history params ["_oldWeapon", "_samples"];
                if (_weapon != _oldWeapon || {
                    _samples isNotEqualTo [] && {
                        _now - ((_samples select - 1) select 0) > 0.3
                    }
                }) then { _samples = []; };
                ((_unit weaponDirection _weapon) call CBA_fnc_vect2Polar) params ["", "_yaw", "_pitch"];
                if (_samples isNotEqualTo []) then {
                    private _last = _samples select - 1;
                    _yaw = (_last select 1) + ([_yaw - (_last select 1)] call CBA_fnc_simplifyAngle180);
                    _pitch = (_last select 2) + ([_pitch - (_last select 2)] call CBA_fnc_simplifyAngle180);
                };
                _samples pushBack [_now, _yaw, _pitch];
                _samples = _samples select {(_x select 0) >= _now - 3};
                _unit setVariable ["J8_nlaw_history", [_weapon, _samples]];
            };
        };
    } forEach allUnits;
}, 0, [0]] call CBA_fnc_addPerFrameHandler;
