# **AdvancedCombine**

## **Funktion**
AdvancedCombine ist ein "Remake" des AdvancedThresher-Script aus dem LS09 (war auch noch im LS11/13 zu finden) und fügt mehrere Realismus-Funktionen bei Mähdreschern hinzu.

Neue Einstellmöglichkeiten:
- Dreschtrommeldrehzahl
- Dreschkorb
- Windstärke
- Sieb

Die Einstellungen können für jede Fruchtart individuell eingestellt werden. Wenn man mit falschen Einstellungen erntet verringert sich der Ertrag.
Mit [Numpad 0] kann ein Info-HUD eingeblendet werden.

## **Einbau**
1. AdvancedCombine.lua und die HUD-Texturen (achud.dds und acicons.dds) in den Fahrzeugordner kopieren
2. Folgende Einträge in der modDesc hinzufügen:
````xml
<!-- in specializations: -->
<specialization name="advancedCombine" className="advancedCombine" filename="AdvancedCombine.lua" />
<!-- in vehicleTypes: -->
<specialization name="advancedCombine" />

<!-- Benötigte InputBindings/l10n: -->
	<inputBinding>
        <actionBinding action="TOGGLE_DISPLAY_MODE">
            <binding device="KB_MOUSE_DEFAULT" input="KEY_KP_4" />
        </actionBinding>
        <actionBinding action="AXIS_THRESHER_RPM">
            <binding device="KB_MOUSE_DEFAULT" input="KEY_KP_7" axisComponent="+"/>
            <binding device="KB_MOUSE_DEFAULT" input="KEY_KP_9" axisComponent="-"/>
        </actionBinding>
        <actionBinding action="AXIS_CONCAVE">
            <binding device="KB_MOUSE_DEFAULT" input="KEY_lalt KEY_KP_7" axisComponent="+"/>
            <binding device="KB_MOUSE_DEFAULT" input="KEY_lalt KEY_KP_9" axisComponent="-"/>
        </actionBinding>
        <actionBinding action="AXIS_WIND_RPM">
            <binding device="KB_MOUSE_DEFAULT" input="KEY_KP_divide" axisComponent="+"/>
            <binding device="KB_MOUSE_DEFAULT" input="KEY_KP_multiply" axisComponent="-"/>
        </actionBinding>
        <actionBinding action="AXIS_SIEVE">
            <binding device="KB_MOUSE_DEFAULT" input="KEY_lalt KEY_KP_divide" axisComponent="+"/>
            <binding device="KB_MOUSE_DEFAULT" input="KEY_lalt KEY_KP_multiply" axisComponent="-"/>
        </actionBinding>
        <actionBinding action="SHOW_SPILL_HUD">
            <binding device="KB_MOUSE_DEFAULT" input="KEY_KP_0" />
        </actionBinding>
    </inputBinding>
    
    <actions>
        <action name="TOGGLE_DISPLAY_MODE" category="VEHICLE" axisType="HALF"/>
        <action name="AXIS_THRESHER_RPM" category="VEHICLE" axisType="FULL"/>
        <action name="AXIS_CONCAVE" category="VEHICLE" axisType="FULL"/>
        <action name="AXIS_WIND_RPM" category="VEHICLE" axisType="FULL"/>
        <action name="AXIS_SIEVE" category="VEHICLE" axisType="FULL"/>
        <action name="SHOW_SPILL_HUD" category="VEHICLE" axisType="HALF"/>
    </actions>

    <l10n>
        <text name="action_CHANGE_THRESHER_RPM"><en>Change threshing drum RPM</en><de>Dreschtrommeldrehzahl ändern</de></text>
        <text name="action_CHANGE_CONCAVE"><en>Change concave distance</en><de>Dreschkorbabstand ändern</de></text>
        <text name="action_CHANGE_WIND_RPM"><en>Change wind speed</en><de>Windstärke ändern</de></text>
        <text name="action_CHANGE_SIEVE"><en>Change sieve setting</en><de>Siebeinstellung ändern</de></text>
        <text name="input_TOGGLE_DISPLAY_MODE"><en>Toggle display mode</en><de>Display-Modus umschalten</de></text>
        <text name="input_AXIS_THRESHER_RPM_1"><en>Increase thresher RPM</en><de>Dreschtrommeldrehzahl erhöhen</de></text>
        <text name="input_AXIS_THRESHER_RPM_2"><en>Decrease thresher RPM</en><de>Dreschtrommeldrehzahl verringern</de></text>
        <text name="input_AXIS_CONCAVE_1"><en>Increase concave distance</en><de>Dreschkorbabstand erhöhen</de></text>
        <text name="input_AXIS_CONCAVE_2"><en>Decrease concave distance</en><de>Dreschkorbabstand verringern</de></text>
        <text name="input_AXIS_WIND_RPM_1"><en>Increase wind RPM</en><de>Winddrehzahl erhöhen</de></text>
        <text name="input_AXIS_WIND_RPM_2"><en>Decrease wind RPM</en><de>Winddrehzahl verringern</de></text>
        <text name="input_AXIS_SIEVE_1"><en>Increase sieve distance</en><de>Siebabstand erhöhen</de></text>
        <text name="input_AXIS_SIEVE_2"><en>Decrease sieve distance</en><de>Siebabstand verringern</de></text>
        <text name="input_SHOW_SPILL_HUD"><en>Show info hud</en><de>Info-HUD anzeigen</de></text>
        <text name="HUD_HARVESTER_SETTINGS"><en>Harvester settings:</en><de>Drescheinstellungen:</de></text>
    </l10n>
````
3. Folgenden Eintrag in der Fahrzeug xml hinzufügen:
````xml
	<advancedCombine>
		<!--rotationPartSpillnadel node="6|1|6|3" minRot="0 0 -15" maxRot="0 0 85" rotTime="10" touchRotLimit="10" /-->
		
		<combineSettings>
			<concave min="1" max="10" />
			<wind min="400" max="950" changeStep="50" />
			<sieve min="1" max="15" />
			<threshingDrum min="650" max="1500" />
		</combineSettings>
		<grainTypes>
			<grainType fruitTypes="wheat" threshingDrumSpeed="1200" concave="3" wind="800" sieve="12" />
			<grainType fruitTypes="oat" threshingDrumSpeed="1250" concave="4" wind="750" sieve="12" />
			<grainType fruitTypes="rye" threshingDrumSpeed="1300" concave="3" wind="750" sieve="12" />
			<grainType fruitTypes="triticale" threshingDrumSpeed="1350" concave="3" wind="750" sieve="13" />
			<grainType fruitTypes="barley" threshingDrumSpeed="1400" concave="2" wind="750" sieve="12" />
			<grainType fruitTypes="spelt" threshingDrumSpeed="1200" concave="3" wind="800" sieve="14" />
			<grainType fruitTypes="soybean sunflower" threshingDrumSpeed="650" concave="4" wind="750" sieve="12" />
			<grainType fruitTypes="maize" threshingDrumSpeed="650" concave="9" wind="900" sieve="13" />
			<grainType fruitTypes="canola" threshingDrumSpeed="750" concave="6" wind="500" sieve="5" />
			<grainType fruitTypes="millet" threshingDrumSpeed="725" concave="6" wind="750" sieve="12" />
		</grainTypes>

		<!-- Dreschtrommelsound -->
		<thresherSound file="sounds/vehicles/engine/claas_dominator/dreschtrommel.wav" linkNode="0|4|0|0" innerRadius="40.0" outerRadius="120.0" >
			<volume indoor="0.5" outdoor="1.4" >
				<modifier type="COMBINE_LOAD" value="0.0" modifiedValue="0.70" />
				<modifier type="COMBINE_LOAD" value="1.0" modifiedValue="1.00" />
				<modifier type="ROTOR_RPM" value="0.20" modifiedValue="0.00" />
				<modifier type="ROTOR_RPM" value="0.50" modifiedValue="1.00" />
				
				<modifier type="CAMERA_ROTATION" value="0.083" modifiedValue="1.00" />
				<modifier type="CAMERA_ROTATION" value="0.125" modifiedValue="0.25" />
				<modifier type="CAMERA_ROTATION" value="0.875" modifiedValue="0.25" />
				<modifier type="CAMERA_ROTATION" value="0.917" modifiedValue="1.00" />
			</volume>
			<pitch indoor="1.0" outdoor="1.0" >
				<modifier type="ROTOR_RPM" value="0.15" modifiedValue="0.65" />
				<modifier type="ROTOR_RPM" value="1" modifiedValue="1.05" />
			</pitch>
			<lowpassGain indoor="2.5" outdoor="1.0" />
		</thresherSound>
		<chopperSound file="sounds/vehicles/engine/claas_dominator/chopper_loop.wav" linkNode="0|8|0|0|0" innerRadius="25.0" outerRadius="110.0" >
			<volume indoor="0.0" outdoor="0.75" >
				<modifier type="CHOPPER_VOLUME" value="0.0" modifiedValue="0.00" />
				<modifier type="CHOPPER_VOLUME" value="1.0" modifiedValue="1.00" />
				<modifier type="CAMERA_ROTATION" value="0.3" modifiedValue="0.15" />
				<modifier type="CAMERA_ROTATION" value="0.4" modifiedValue="1.00" />
				<modifier type="CAMERA_ROTATION" value="0.6" modifiedValue="1.00" />
				<modifier type="CAMERA_ROTATION" value="0.7" modifiedValue="0.15" />
			</volume>
			<pitch indoor="1.0" outdoor="1.0" >
				<modifier type="COMBINE_LOAD" value="0.0" modifiedValue="1.02" />
				<modifier type="COMBINE_LOAD" value="1.0" modifiedValue="1.00" />
			</pitch>
			<lowpassGain indoor="2.5" outdoor="1.0" />
		</chopperSound>
		
        <dashboards>
			<dashboard displayType="ANIMATION" valueType="speedRotorRPM" animName="rpmNeedle" minValueAnim="100" maxValueAnim="2500" doInterpolation="true" interpolationSpeed="1.67" groups="MOTOR_ACTIVE"/>
        </dashboards>
	</advancedCombine>
````
*Diese Config ist von einem Claas Dominator und kann z.B. in den Dominator 108SL von GIANTS kopiert werden. Die Sounds sind im Unterordner sounds verfügbar.*

Erklärung für alle Einträge:
- `combineSettings`: Hier werden alle Einstellungsbereiche definiert. Beispiel: In welchem Bereich kann man die Trommeldrehzahl einstellen. Zusätzlich kann man die Änderungsgröße einstellen mit `changeStep` (bei concave, wind und sieve) oder `changeSpeed` (bei threshingDrum). Standard ist der Wert 1.
- `grainTypes`: Hier werden die Einstellungen pro Fruchtart definiert.
- `thresherSound`: Hier kann ein Dreschtrommelsound eingetragen werden.
- `chopperSound`: Hier kann ein Strohhäckslersound eingetragen werden.
- `dashboards`: Es kann ein Dashboard mit `valueType="speedRotorRPM"` angegeben werden, falls der Drescher eine Anzeige besitzt die sowohl die Fahrgeschwindigkeit als auch die Trommeldrehzahl (abwechselnd) angezeigen kann. Anzeige ist umschaltbar mit [Numpad 4].

Es gibt zudem neue Sound-Modifizierer. `ROTOR_RPM` ist die Dreschtrommeldrehzahl im Bereich 0-1. `CHOPPER_VOLUME` ist für die Lautstärke des Strohhäckslersounds. `CAMERA_ROTATION` gibt die aktuelle Kamera-Rotation wieder, ebenfalls im Bereich 0-1. 0 ist Ansicht von vorne, 0.5 ist Ansicht von hinten und 1 wieder Ansicht von vorne. Die Drehung ist entgegen dem Uhrzeigersinn, das heißt 0.25 ist Ansicht von links und 0.75 von rechts.
