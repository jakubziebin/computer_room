#!/bin/bash

#zmienne pomocnicze do określania czy okno może być otwarte (jeśli 1 to może być otwarte ze względu na dany parametr)
OPENWINDOW_RAIN=0
OPENWINDOW_WIND=0
OPENWINDOW_TEMP_OUT_NOW=0

#zmienne limitujące progi
WIND_LIMIT=1000
OPTIMAL_TEMP=$(tail -n 1 /var/www/html/PBL/php/otwieranie/wartosc_temp.txt) #TUUUUUUU brakuje chyba razy 100

#zmienne czasowe do odpowiednich warunków
WEB_TIME=$(date '+%s')
MEASURMENTS_TIME=$(date '+%s')

#zmienne z nazwami plików
OUTSIDE_TEMP_NOW_FILE="/var/www/html/PBL/php/temperatura_srednia/srednia_temp_zew.txt" #temperatura aktualna wywietlana w indexie
OUTSIDE_TEMP_AVARAGE_FILE="/var/www/html/PBL/php/temperatura_dzienna/temperatura_zewnatrz.txt" #Srednia temperatura z calego dnia i tak miesiac razy
OUTSIDE_TEMP_DAY_FILE="/var/www/html/PBL/php/temperatura_godzina_zew/temperatura.txt" #to będzie ściezka do zbioru 24h
OUTSIDE_HUMIDITY_FILE="/var/www/html/PBL/php/temperatura_godzina_zew/wilgotnosc.txt"
OUTSIDE_PREASURE="/var/www/html/PBL/php/temperatura_godzina_zew/cisnienie.txt"
OUTSIDE_HOUR="/var/www/html/PBL/php/temperatura_godzina_zew/godziny.txt"

INSIDE_TEMP_NOW_FILE="/var/www/html/PBL/php/temperatura_srednia/srednia_temp_wew.txt" #srednia z ostatniej godziny
INSIDE_TEMP_AVARAGE_FILE="/var/www/html/PBL/php/temperatura_dzienna/temperatura_wewnatrz.txt" #30 dni
INSIDE_TEMP_DAY_FILE_SENSOR1="/var/www/html/PBL/php/temperatura_godzina_wew/czujnik1_wew.txt" #24 h
INSIDE_TEMP_DAY_FILE_SENSOR2="/var/www/html/PBL/php/temperatura_godzina_wew/czujnik2_wew.txt"
INSIDE_TEMP_DAY_FILE_SENSOR3="/var/www/html/PBL/php/temperatura_godzina_wew/czujnik3_wew.txt"
INSIDE_HOUR="/var/www/html/PBL/php/temperatura_godzina_wew/godziny.txt"
INSIDE_HOUR_AVARAGE_FILE="/var/www/html/PBL/php/temperatura_godzina_wew/godzinne_srednie.txt"

WEATHER_FROM_INTERNET="/home/pbl/Dokumenty/PBL/py_pogoda.py"
HUM_FROM_SENSOR_PATH="/home/pbl/Dokumenty/PBL/py_humidity.py"
TEMP_FROM_SENSOR1_PATH="/home/pbl/Dokumenty/PBL/py_temperature1.py"
TEMP_FROM_SENSOR2_PATH="/home/pbl/Dokumenty/PBL/py_temperature2.py"
TEMP_FROM_SENSOR3_PATH="/home/pbl/Dokumenty/PBL/py_temperature3.py"

DIAG="/var/www/html/PBL/php/diagnostyka" # wewnatrz pliki tekstowe w formacie diagnostyka_czujnik1_wew.txt (ew zew)

CHANGE_LIBRARY_DATA="/var/www/html/PBL/php/dziennik/data.txt"
CHANGE_LIBRARY_OPERATION="/var/www/html/PBL/php/dziennik/operacja.txt"
CHANGE_LIBRARY_HOUR="/var/www/html/PBL/php/dziennik/godzina.txt"
CHANGE_LIBRARY_REASON="/var/www/html/PBL/php/dziennik/przyczyna.txt"

CHOOSE_TEMPERATURE="/var/www/html/PBL/php/otwieranie/wartosc_temp.txt" #zadana temperatura przez uzytkownika
MANUAL_PROCES_FILE="/var/www/html/PBL/php/otwieranie/proces.txt" #otwieranielub zamykanie okna w trybie recznym
OPERATION_MODE="/var/www/html/PBL/php/otwieranie/tryb_pracy.txt"
OPTIMAL_TEMPERATURE="/var/www/html/PBL/php/temperatura_srednia/temperatura_opt.txt" #ta ze wzoru
DELTA_FILE="/var/www/html/PBL/php/otwieranie/histereza.txt"
DAY_DATA="/var/www/html/PBL/php/temperatura_dzienna/data.txt" #dzie miesiaca

#---------------
# PLIKI ISE
#---------------

ISE_SENSOR1="/home/pbl/Dokumenty/DANE/txt_temperatura_wewnetrzna1.txt"
ISE_SENSOR2="/home/pbl/Dokumenty/DANE/txt_temperatura_wewnetrzna2.txt"
ISE_SENSOR3="/home/pbl/Dokumenty/DANE/txt_temperatura_wewnetrzna3.txt"
ISE_TEMP_ZEW="/home/pbl/Dokumenty/DANE/txt_temperatura_zewnetrzna.txt"
ISE_DZIENNIK="/home/pbl/Dokumenty/DANE/txt_dziennik_zmian.txt"

USB_PATH="/media/pbl"
USB_NAME1="DANE_PBL"
USB_NAME2="REZERWA_PBL"
#--------------
#ZMIENNE
#--------------

#zmienne do otwierania okna
CLOSE_HELP=1
OPEN_HELP=1

#zienna do iteracji
j=0
k=0

# wagi do średniej z czujników
A=100
B=75
C=50

# wagi do temp optymalnej temperatury
WAGA0=1000
WAGA1=800
WAGA2=640
WAGA3=512
WAGA4=409
WAGA5=328
WAGA6=262


#--------------
#DEKLARACJE PINOW
#--------------
# gpio 2, 3 i 4 zajęte pod sesnory DHT22
MOVE_WINDOW_PIN=5 #przekaźnik otwieranie okna
echo $MOVE_WINDOW_PIN > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$MOVE_WINDOW_PIN/direction

OPEN_CLOSE_WINDOW_PIN=6
echo $OPEN_CLOSE_WINDOW_PIN > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$OPEN_CLOSE_WINDOW_PIN/direction

KONTRAKTON_OPEN_PIN=19
echo $KONTRAKTON_OPEN_PIN > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio$KONTRAKTON_OPEN_PIN/direction

KONTRAKTON_CLOSE_PIN=26
echo $KONTRAKTON_CLOSE_PIN > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio$KONTRAKTON_CLOSE_PIN/direction

CO2_PIN=20
echo $CO2_PIN > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio$CO2_PIN/direction



#--------------
# PROGRAM
#--------------


START_DATA=$(date)
echo  "$START_DATA WlaczenieSystemu" >> $ISE_DZIENNIK

while [ 1 ] ; do
	DATA=($(date))
	CURRENT_TIME=$(date '+%s')


#--------------------------------------------------------------------------------------------------
#zczytanie optymalnej temperatury z pliku i przeliczenie jej na odpowiedni zakres
#--------------------------------------------------------------------------------------------------
OPTIMAL_TEMP=$(tail -n 1 /var/www/html/PBL/php/otwieranie/wartosc_temp.txt | tr -d '.')
let OPTIMAL_TEMP=OPTIMAL_TEMP*10



#echo "while"
	if [[ $CURRENT_TIME -gt $(($WEB_TIME + 3600)) ]]; then # zmienic na 3600, zeby co godzine pobierao dane ze strony
#echo "IF ZEWNETRZNY"
		WEB_TIME=$(date '+%s')


                #--------------------------------------------------------------------------------------------------
                #liczenie optymalnej temperatury ze wzoru
                #--------------------------------------------------------------------------------------------------

		OPTIMAL_LIMIT_TAB=($(tail -n 7 $OUTSIDE_TEMP_AVARAGE_FILE | tr -d '.' | tr -d '\r'))
		TEMP=$(echo "scale=2; $WAGA0*${OPTIMAL_LIMIT_TAB[6]}+$WAGA1*${OPTIMAL_LIMIT_TAB[5]}+$WAGA2*${OPTIMAL_LIMIT_TAB[4]}+$WAGA3*${OPTIMAL_LIMIT_TAB[3]}+$WAGA4*${OPTIMAL_LIMIT_TAB[2]}+$WAGA5*${OPTIMAL_LIMIT_TAB[1]}+$WAGA6+${OPTIMAL_LIMIT_TAB[0]}" | bc)
		echo "scale=2; 0.33*0.2*$TEMP/10000+18.8 " | bc > $OPTIMAL_TEMPERATURE
		OPTIMAL_LIMIT=$(tail -n 1 $OPTIMAL_TEMPERATURE | tr -d '.' | tr -d '\r')
		echo "TEMP OPTYMALNA: $OPTIMAL_LIMIT"





		#przesył danych ze strony internetowej na temat pogody w Gliwicach
		OUTSIDE_WEATHER=($(python3 $WEATHER_FROM_INTERNET))


		#--------------------------------------------------------------------------------------------------
		#wycięcie informacji o temperaturze zewnętrznej
                #--------------------------------------------------------------------------------------------------

		OUTSIDE_TEMPERATURE_NOW=$(tr -d '.' <<< ${OUTSIDE_WEATHER[0]})
		#OUTSIDE_TEMPERATURE_NOW=1300
		echo ""
		echo "$OUTSIDE_TEMPERATURE_NOW"
		echo ""

		if [[ $OUTSIDE_TEMPERATURE_NOW -gt $OPTIMAL_LIMIT ]]; then
			echo "Okno może byc otwarte ze względu na chwilową temperature zewnętrzną"
			OPENWINDOW_TEMP_OUT_NOW=1
		else
			echo "Zamknij okno"
			OPENWINDOW_TEMP_OUT_NOW=0
		fi




                #--------------------------------------------------------------------------------------------------
		#wycięcie informacji o sile wiatru
                #--------------------------------------------------------------------------------------------------

		WIND=$(tr -d '.' <<< ${OUTSIDE_WEATHER[2]})
		#WIND=111
		echo ""
		echo "$WIND"
		echo ""

		if [[ $WIND -gt $WIND_LIMIT ]]; then
			echo "Zamknij okno"
			OPENWINDOW_WIND=0
		else
			 echo "Okno może być otwarte ze względu na wiatr"
			OPENWINDOW_WIND=1
		fi




                #--------------------------------------------------------------------------------------------------
		#wycięcie informacji o opadach
                #--------------------------------------------------------------------------------------------------

		RAIN=${OUTSIDE_WEATHER[4]}
		#RAIN="Clear sky"
		echo ""
		echo "$RAIN"
		echo ""


		if [[ $RAIN = "Clear sky" ]] || [[ $RAIN = "Few clouds" ]] || [[ $RAIN = "Scattered clouds" ]] || [[ $RAIN = "Broken clouds" ]] || [[ $RAIN = "Mist" ]] || [[ $RAIN = "Fog" ]] || [[ $RAIN = "Haze" ]] || [[ $RAIN = "Clear" ]] || [[ $RAIN = "Clouds" ]]; then
			echo "Okno może być otwarte ze względu na deszcz"
			OPENWINDOW_RAIN=1
		else
			echo "Zamknij okno"
			OPENWINDOW_RAIN=0
		fi



		#----------------------------------------------------------------------->
                #wyciecie informacji o cisnieniu i wilgotnosci
                #----------------------------------------------------------------------->
		echo "${OUTSIDE_WEATHER[1]}" >> $OUTSIDE_HUMIDITY_FILE
		echo "${OUTSIDE_WEATHER[3]}" >> $OUTSIDE_PREASURE
		OUT_DATE=($(date | tr -d ',' | tr ':' ' '))
		echo "${OUT_DATE[4]}:${OUT_DATE[5]}" >> $OUTSIDE_HOUR


		#--------------------------------------------------------------------------------------------------
		#zapis do pliku temperatury otoczenia
		#--------------------------------------------------------------------------------------------------


		echo "scale=1; $OUTSIDE_TEMPERATURE_NOW/100" | bc > $OUTSIDE_TEMP_NOW_FILE
		echo "$(date) $OUTSIDE_TEMPERATURE_NOW">> $ISE_TEMP_ZEW
		echo "scale=1; $OUTSIDE_TEMPERATURE_NOW/100" | bc >> $OUTSIDE_TEMP_DAY_FILE

		MEASURMENTS=($(wc -l $OUTSIDE_TEMP_NOW_FILE))
                if [[ $MEASURMENTS -gt 24 ]]; then
                        OUT_TEMP=$(tail +24 $OUTSIDE_TEMP_NOW_FILE)
                        echo "$OUT_TEMP" > $OUTSIDE_TEMP_NOW_FILE
			OUT_PRES=$(tail +24 $OUTSIDE_PREASURE)
			echo "$OUT_PRES" > $OUTSIDE_PREASURE
			OUT_HUM=$(tail +24 $OUTSIDE_HUMIDITY_FILE)
                        echo "$OUT_HUM" > $OUTSIDE_HUMIDITY_FILE
			OUT_HOUR=$(tail +24 $OUTSIDE_HOUR)
			echo "$OUT_HOUR" > $OUTSIDE_HOUR

                fi


		MEASURMENTS=($(wc -l $ISE_TEMP_ZEW))
                if [[ $MEASURMENTS -gt 2400 ]]; then
                        ISE_ZEW=$(tail +2400 $ISE_TEMP_ZEW)
                        echo "$ISE_ZEW" > $ISE_TEMP_ZEW
		fi


		#--------------------------------------------------------------------------------------------------
                #liczenie średniej z dnia
                #--------------------------------------------------------------------------------------------------
		MIDNIGHT=($(date | tr ':' ' '))

		if [[ ${MIDNIGHT[4]} -eq "00" ]]; then
		        OUTSIDE_TEMP_TO_AVARAGE=($(cat $OUTSIDE_TEMP_DAY_FILE | tr -d '\r'))
			SUM=0;
			DIVIDER=($(wc -l $OUTSIDE_TEMP_DAY_FILE))
			for (( i=0; $i < $DIVIDER; i++)) ;do
				SUM=$(($SUM + ${OUTSIDE_TEMP_TO_AVARAGE[$i]}))
			done

			let OUTSIDE_TEMPERATURE_AVARAGE=SUM/i
			echo "scale=1; $SUM/$i" | bc >> $OUTSIDE_TEMP_AVARAGE_FILE
			> $OUTSIDE_TEMP_DAY_FILE #czyszczenie pliku przechowujacego dane o temperaturze dziennej

			#jesli 30dniowy plik przekroczyl 30 pozycji nalezy pierwsza skasowac
			NUMBER=($(wc -l $OUTSIDE_TEMP_AVARAGE_FILE))
			if [[ $NUMBER -gt 30 ]]; then
				OUT_DANE_DAY=$(tail +30 $OUTSIDE_TEMP_AVARAGE_FILE)
				echo "$OUT_DANE_DAY" > $OUTSIDE_TEMP_AVARAGE_FILE
			fi


		fi



		#--------------------------------------------------------------------------------------------------
                # zapis do USB
                #--------------------------------------------------------------------------------------------------


		ALL_USB=($(ls $USB_PATH))
		for i in ${!ALL_USB[@]} ; do
			if [[ ${ALL_USB[$i]} = "$USB_NAME1" ]]; then
				WHERE_AM_I=$(pwd)
				rm -r $USB_PATH/${ALL_USB[$i]}/DANE
				cp -r $WHERE_AM_I/../DANE $USB_PATH/${ALL_USB[$i]}
			fi
		done

		ALL_USB=($(ls $USB_PATH))
		for i in ${!ALL_USB[@]} ; do
			if [[ ${ALL_USB[$i]} = "$USB_NAME2" ]]; then
				WHERE_AM_I=$(pwd)
				rm -r $USB_PATH/${ALL_USB[$i]}/DANE
				cp -r $WHERE_AM_I/../DANE $USB_PATH/${ALL_USB[$i]}
			fi
		done

	fi #powtorzenie co x czasu -> zczytywanie danych ze stronki i liczenie sredniej




#echo "Za if zewnetrzny"

	HELP_TO_FILE=($(wc -l $OUTSIDE_TEMP_DAY_FILE))
	if [[ ${HELP_TO_FILE[0]} = 24 ]]; then  #teoretycznie nigdy nie powinno sie wykonac ale tak na wszelki wypadek
#echo "TUTAJ?"
		 OUTSIDE_TEMP_TO_AVARAGE=($(cat $OUTSIDE_TEMP_DAY_FILE))
                 SUM=0;
                 DIVIDER=($(wc -l $OUTSIDE_TEMP_DAY_FILE))
                 for (( i=0; $i < $DIVIDER; i++)) ;do
	                 SUM=$(($SUM + ${OUTSIDE_TEMP_TO_AVARAGE[$i]}))
                 done

                 let OUTSIDE_TEMPERATURE_AVARAGE=SUM/i
                 echo "scale=1; $SUM/$i" | bc >> $OUTSIDE_TEMP_AVARAGE_FILE
                 > $OUTSIDE_TEMP_DAY_FILE #czyszczenie pliku przechowujacego dane o temperaturze dziennej

                 #jesli 30dniowy plik przekroczyl 30 pozycji nalezy pierwsza skasowac
                 NUMBER=($(wc -l $OUTSIDE_TEMP_AVARAGE_FILE))
                 if [[ $NUMBER -gt 30 ]]; then
	                 OUT_DANE_DAY=$(tail +30 $OUTSIDE_TEMP_AVARAGE_FILE)
                         echo "$OUT_DANE_DAY" > $OUTSIDE_TEMP_AVARAGE_FILE
		fi
	fi



#echo "Za tym if co się nigdy nie wykona"

	if [[ $CURRENT_TIME -gt $(($MEASURMENTS_TIME + 180)) ]]; then

		echo "Odczyt temp z czujników wewnętrznych"
		MEASURMENTS_TIME=$(date '+%s')

		#--------------------------------------------------------------------------------------------------
		#odczyt temperatury z czujnikow
		#--------------------------------------------------------------------------------------------------

		TEMP_FROM_SENSOR1=$(python3 $TEMP_FROM_SENSOR1_PATH | tr -d '.' | tr -d '\r')
		TEMP_FROM_SENSOR2=$(python3 $TEMP_FROM_SENSOR2_PATH | tr -d '.' | tr -d '\r')
		TEMP_FROM_SENSOR3=$(python3 $TEMP_FROM_SENSOR3_PATH | tr -d '.' | tr -d '\r')


		if [[ -z $TEMP_FROM_SENSOR1 ]]; then
			TEMP_FROM_SENSOR1=1000
		fi

                if [[ -z $TEMP_FROM_SENSOR2 ]]; then
                        TEMP_FROM_SENSOR2=1000
                fi

                if [[ -z $TEMP_FROM_SENSOR3 ]]; then
                        TEMP_FROM_SENSOR3=1000
                fi


		COUNTER=0
		SUM=0
		if [[ $TEMP_FROM_SENSOR1 -gt 50 ]] && [[ $TEMP_FROM_SENSOR1 -lt 450 ]]; then
			COUNTER=$(($COUNTER + $A))
			let TEMPORARY=TEMP_FROM_SENSOR1*A
			SUM=$(($SUM + $TEMPORARY))
			SENSOR1_TAB[$k]=$TEMP_FROM_SENSOR1

			echo "1" > $DIAG/diagnostyka_czujnik1_wew.txt
			echo "$(date) $TEMP_FROM_SENSOR1" >> $ISE_SENSOR1
		else
			echo "0" > $DIAG/diagnostyka_czujnik1_wew.txt
			echo "$(date) BLAD CZUJNIKA" >> $ISE_SENSOR1
		fi

		if [[ $TEMP_FROM_SENSOR2 -gt 50 ]] && [[ $TEMP_FROM_SENSOR2 -lt 450 ]]; then
                        COUNTER=$(($COUNTER + $B))
                        let TEMPORARY=TEMP_FROM_SENSOR2*B
                        SUM=$(($SUM + $TEMPORARY))
			SENSOR2_TAB[$k]=$TEMP_FROM_SENSOR2

			echo "1" > $DIAG/diagnostyka_czujnik2_wew.txt
			echo "$(date) $TEMP_FROM_SENSOR2" >> $ISE_SENSOR2
		else
			echo "0" > $DIAG/diagnostyka_czujnik2_wew.txt
			echo "$(date) BLAD CZUJNIKA" >> $ISE_SENSOR2

                fi

		if [[ $TEMP_FROM_SENSOR3 -gt 50 ]] && [[ $TEMP_FROM_SENSOR3 -lt 450 ]]; then
                        COUNTER=$(($COUNTER + $C))
                        let TEMPORARY=TEMP_FROM_SENSOR3*C
                        SUM=$(($SUM + $TEMPORARY))
			SENSOR3_TAB[$k]=$TEMP_FROM_SENSOR3

                	echo "1" > $DIAG/diagnostyka_czujnik3_wew.txt
			echo "$(date) $TEMP_FROM_SENSOR3" >> $ISE_SENSOR3
		else
			echo "0" > $DIAG/diagnostyka_czujnik1_wew.txt
			echo "$(date) BLAD CZUJNIKA" >> $ISE_SENSOR3

		fi

		MEASURMENTS=($(wc -l $ISE_SENSOR1))
		if [[ $MEASURMENTS -gt 48000 ]]; then
                        SENS1_ISE=$(tail +48000 $ISE_SENSOR1)
                        echo "$SENS1_ISE" > $ISE_SENSOR1
			SENS2_ISE=$(tail +48000 $ISE_SENSOR2)
                        echo "$SENS2_ISE" > $ISE_SENSOR2
			SENS3_ISE=$(tail +48000 $ISE_SENSOR3)
                        echo "$SENS3_ISE" > $ISE_SENSOR3
                fi

                #--------------------------------------------------------------------------------------------------
                #średnia ważona temperatury z czujników wewnetrznych
                #--------------------------------------------------------------------------------------------------
                #let INSIDE_TEMPERATURE_AVARAGE=SUM/COUNTER
                INSIDE_TEMPERATURE_AVARAGE[$k]=$(echo "$SUM/$COUNTER" | bc)
		echo "scale=1; ${INSIDE_TEMPERATURE_AVARAGE[$k]}/10" | bc > $INSIDE_TEMP_NOW_FILE


		#--------------------------------------------------------------------------------------------------
                #średnia arytmetyczna z pomiarów z godziny
                #--------------------------------------------------------------------------------------------------


		k=$(($k+1))
		echo "k = $k"
		if [[ $k = 20 ]]; then
			SENSOR1=0
			SENSOR1_COUNTER=0
			SENSOR2=0
			SENSOR2_COUNTER=0
			SENSOR3=0
			SENSOR3_COUNTER=0
			SUM=0
			for i in {0..19}; do
				if [[ -n ${SENSOR1_TAB[$i]} ]]; then
					let SENSOR1=SENSOR1+SENSOR1_TAB[i]
					#echo "TAB1 = ${SENSOR1_TAB[$i]}"
					#echo "SENSOR1 = $SENSOR1"
					SENSOR1_COUNTER=$(($SENSOR1_COUNTER+1))
				fi

				if [[ -n ${SENSOR2_TAB[$i]} ]]; then
                                        let SENSOR2=SENSOR2+SENSOR2_TAB[i]
                                        #echo "TAB2 = ${SENSOR2_TAB[$i]}"
                                        #echo "SENSOR2 = $SENSOR2"
                                        SENSOR2_COUNTER=$(($SENSOR2_COUNTER+1))
                                fi
				if [[ -n ${SENSOR3_TAB[$i]} ]]; then
                                        let SENSOR3=SENSOR3+SENSOR3_TAB[i]
                                        #echo "TAB3 = ${SENSOR3_TAB[$i]}"
                                        #echo "SENSOR3 = $SENSOR3"
                                        SENSOR3_COUNTER=$(($SENSOR3_COUNTER+1))
                                fi

				SUM=$(($SUM+${INSIDE_TEMPERATURE_AVARAGE[$i]})) #srednia z godziny liczona na podstawie średnich ważonych z pojedynczych pomiarów
			done

			if [[ $SENSOR1_COUNTER > 0 ]]; then
				echo "scale=1; $SENSOR1/$SENSOR1_COUNTER/10" | bc >> $INSIDE_TEMP_DAY_FILE_SENSOR1
			else
				echo "BLAD" >> $INSIDE_TEMP_DAY_FILE_SENSOR1
			fi

			if [[ $SENSOR2_COUNTER > 0 ]]; then
                                echo "scale=1; $SENSOR2/$SENSOR2_COUNTER/10" | bc >> $INSIDE_TEMP_DAY_FILE_SENSOR2
                        else
                                echo "BLAD" >> $INSIDE_TEMP_DAY_FILE_SENSOR2
                        fi

			if [[ $SENSOR3_COUNTER > 0 ]]; then
                                echo "scale=1; $SENSOR3/$SENSOR3_COUNTER/10" | bc >> $INSIDE_TEMP_DAY_FILE_SENSOR3
                        else
                                echo "BLAD" >> $INSIDE_TEMP_DAY_FILE_SENSOR3
                        fi


			INSIDE_NUMBER=($(wc -l $INSIDE_TEMP_DAY_FILE_SENSOR1))
                        if [[ $INSIDE_NUMBER -gt 24 ]]; then
                                INS_DAY_TEMP1=$(tail +24 $INSIDE_TEMP_DAY_FILE_SENSOR1)
                                echo "$INS_DAY_TEMP1" > $INSIDE_TEMP_DAY_FILE_SENSOR1
				INS_DAY_TEMP2=$(tail +24 $INSIDE_TEMP_DAY_FILE_SENSOR2)
                                echo "$INS_DAY_TEMP2" > $INSIDE_TEMP_DAY_FILE_SENSOR2
				INS_DAY_TEMP3=$(tail +24 $INSIDE_TEMP_DAY_FILE_SENSOR3)
                                echo "$INS_DAY_TEMP3" > $INSIDE_TEMP_DAY_FILE_SENSOR3
                        fi




               		echo "scale=1; $SUM/200" | bc >> $INSIDE_HOUR_AVARAGE_FILE
			INS_DATE=($(date | tr -d ',' | tr ':' ' '))
                	echo "${INS_DATE[4]}:${INS_DATE[5]}" >> $INSIDE_HOUR

			k=0
		fi



                #--------------------------------------------------------------------------------------------------
                #otwieranie okna
                #--------------------------------------------------------------------------------------------------
		DELTA=$(tail -n 1 $DELTA_FILE | tr -d '.')
		USER_TEMPERATURE=$(tail -n 1 $CHOOSE_TEMPERATURE | tr -d '.')

		if [[ ${INSIDE_TEMPERATURE_AVARAGE[$k]} -gt $(($USER_TEMPERATURE + $DELTA)) ]]; then
			OPENWINDOW_TEMP_IN_NOW=1
		elif [[ ${INSIDE_TEMPERATURE_AVARAGE[$k]} -lt $(($USER_TEMPERATURE - $DELTA)) ]]; then
			OPENWINDOW_TEMP_IN_NOW=0
		fi




                #--------------------------------------------------------------------------------------------------
                #średnia do pliku
                #--------------------------------------------------------------------------------------------------

		#jesli z jakiegos dziwnego powodu przekroczylo 24 pozycje
                NUMBER=($(wc -l $INSIDE_HOUR_AVARAGE_FILE))
                if [[ $NUMBER -gt 24 ]]; then
			INS_DANE_HOUR=$(tail +24 $INSIDE_HOUR_AVARAGE_FILE)
                        echo "$INS_DANE_HOUR" > $INSIDE_HOUR_AVARAGE_FILE
			INS_HOUR=$(tail +24 $INSIDE_HOUR)
                        echo "$INS_HOUR" > $INSIDE_HOUR
                fi




		MIDNIGHT=($(date | tr ':' ' '))

                if [[ ${MIDNIGHT[4]} -eq "00" ]] && [[ ${MIDNIGHT[5]} -gt "00" ]] && [[ ${MIDNIGHT[5]} -lt "02" ]]; then
                        INSIDE_TEMP_TO_AVARAGE=($(cat $INSIDE_HOUR_AVARAGE_FILE | tr -d '.'))
                        SUM=0;
                        DIVIDER=($(wc -l $INSIDE_HOUR_AVARAGE_FILE))
                        for (( i=0; i<DIVIDER; i++)) ;do
                                SUM=$(($SUM+${INSIDE_TEMP_TO_AVARAGE[i]}))
                        done

                        echo "scale=1; $SUM/20" | bc >> $INSIDE_TEMP_AVARAGE_FILE
                        > $INSIDE_HOUR_AVARAGE_FILE #czyszczenie pliku przechowujacego dane o temperaturze dziennej
			DAY=($(date | tr -d ','))
			echo "${DAY[1]} ${DAY[2]} $DAY[3]" >> $DAY_DATA
                        #jesli 30dniowy plik przekroczyl 30 pozycji nalezy pierwsza skasowac
                        NUMBER=($(wc -l $INSIDE_TEMP_AVARAGE_FILE))
                        if [[ $NUMBER -gt 30 ]]; then
                                INS_DANE_DAY=$(tail +30 $INSIDE_TEMP_AVARAGE_FILE)
                                echo "$INS_DANE_DAY" > $INSIDE_TEMP_AVARAGE_FILE
                                DANE_DATE=$(tail +30 $DAY_DATA)
                                echo "$DANE_DATE" > $DAY_DATA
                        fi


                fi


		#--------------------------------------------------------------------------------------------------
        	#sprawdzanie poziomu CO2
        	#--------------------------------------------------------------------------------------------------

		OPENWINDOW_CO2=$(tail -n 1 /sys/class/gpio/gpio$CO2_PIN/value)


	fi #koniec warunku temperatury wewnetrznej


#echo "Za if temp wewnętrznej"

	MODE=$(tail -n 1 $OPERATION_MODE)
	if [[ $MODE = 1 ]]; then #jeżeli automat
		echo "automat"
		if [[ $OPENWINDOW_RAIN = 1 ]] && [[ $OPENWINDOW_WIND = 1 ]] && [[ $OPENWINDOW_TEMP_OUT_NOW = 1 ]] && [[ $OPENWINDOW_TEMP_IN_NOW = 1 ]]; then
			IS_WINDOW_OPEN=$(tail -n 1 /sys/class/gpio/gpio$KONTRAKTON_OPEN_PIN/value)
                        if [[ $IS_WINDOW_OPEN = 0 ]]; then
                                echo 1 > /sys/class/gpio/gpio$OPEN_CLOSE_WINDOW_PIN/value
                                echo 1 > /sys/class/gpio/gpio$MOVE_WINDOW_PIN/value
                                if [[ $OPEN_HELP = 1 ]]; then
					echo "$(date) ZbytWysokaTemperatura Otwieranie okna" >> $ISE_DZIENNIK
                                	DATA_TO_FILE=($(date | tr -d ','))
                                	echo "${DATA_TO_FILE[1]} ${DATA_TO_FILE[2]} ${DATA_TO_FILE[3]}" >> $CHANGE_LIBRARY_DATA
                                	echo "${DATA_TO_FILE[4]}" >> $CHANGE_LIBRARY_HOUR
                                	echo "Otwieranie okna" >> $CHANGE_LIBRARY_OPERATION
                                	echo "Zbyt wysoka temperatura" >> $CHANGE_LIBRARY_REASON

                                	ISE_RECORDS=($(wc -l $ISE_DZIENNIK))
                                	if [[ $ISE_RECORDS -gt 5000 ]]; then
                                	        ISE_DIARY=$(tail +5000 $ISE_DZIENNIK)
                                	        echo "$ISE_DIARY" > $ISE_DZIENNIK
                                	fi

                                	RECORDS=($(wc -l $CHANGE_LIBRARY_OPERATION))
                                	if [[ $RECORDS -gt 15 ]]; then
                                	        CHANGES=$(tail +15 $CHANGE_LIBRARY_OPERATION)
                                        	echo "$CHANGES" > $CHANGE_LIBRARY_OPERATION
                                        	CHANGES=$(tail +15 $CHANGE_LIBRARY_REASON)
                                        	echo "$CHANGES" > $CHANGE_LIBRARY_REASON
                                        	CHANGES=$(tail +15 $CHANGE_LIBRARY_HOUR)
                                        	echo "$CHANGES" > $CHANGE_LIBRARY_HOUR
                                        	CHANGES=$(tail +15 $CHANGE_LIBRARY_DATA)
                                        	echo "$CHANGES" > $CHANGE_LIBRARY_DATA
                                	fi
					OPEN_HELP=0
				fi

			else
                                echo 0 > /sys/class/gpio/gpio$MOVE_WINDOW_PIN/value
                                echo 0 > /sys/class/gpio/gpio$OPEN_CLOSE_WINDOW_PIN/value
				OPEN_HELP=1
				CLOSE_HELP=1
                        fi

		elif [[ $OPENWINDOW_CO2 = 1 ]]; then
			IS_WINDOW_OPEN=$(tail -n 1 /sys/class/gpio/gpio$KONTRAKTON_OPEN_PIN/value)
                        if [[ $IS_WINDOW_OPEN = 0 ]]; then
                                echo 1 > /sys/class/gpio/gpio$OPEN_CLOSE_WINDOW_PIN/value
                                echo 1 > /sys/class/gpio/gpio$MOVE_WINDOW_PIN/value
                                if [[ $OPEN_HELP = 1 ]]; then
					echo "$(date) ZbytWysokieCO2 Otwieranie okna" >> $ISE_DZIENNIK
                                	DATA_TO_FILE=($(date | tr -d ','))
                                	echo "${DATA_TO_FILE[1]} ${DATA_TO_FILE[2]} ${DATA_TO_FILE[3]}" >> $CHANGE_LIBRARY_DATA
                                	echo "${DATA_TO_FILE[4]}" >> $CHANGE_LIBRARY_HOUR
                                	echo "Otwieranie okna" >> $CHANGE_LIBRARY_OPERATION
                                	echo "Zbyt duzo CO2" >> $CHANGE_LIBRARY_REASON

                                	ISE_RECORDS=($(wc -l $ISE_DZIENNIK))
                                	if [[ $ISE_RECORDS -gt 5000 ]]; then
                                	        ISE_DIARY=$(tail +5000 $ISE_DZIENNIK)
                                        	echo "$ISE_DIARY" > $ISE_DZIENNIK
                                	fi

                                	RECORDS=($(wc -l $CHANGE_LIBRARY_OPERATION))
                                	if [[ $RECORDS -gt 15 ]]; then
                                        	CHANGES=$(tail +15 $CHANGE_LIBRARY_OPERATION)
                                        	echo "$CHANGES" > $CHANGE_LIBRARY_OPERATION
                                        	CHANGES=$(tail +15 $CHANGE_LIBRARY_REASON)
                                        	echo "$CHANGES" > $CHANGE_LIBRARY_REASON
                                        	CHANGES=$(tail +15 $CHANGE_LIBRARY_HOUR)
                                        	echo "$CHANGES" > $CHANGE_LIBRARY_HOUR
                                        	CHANGES=$(tail +15 $CHANGE_LIBRARY_DATA)
                                        	echo "$CHANGES" > $CHANGE_LIBRARY_DATA
                                	fi
					OPEN_HELP=0
				fi
                        else
                                echo 0 > /sys/class/gpio/gpio$MOVE_WINDOW_PIN/value
                                echo 0 > /sys/class/gpio/gpio$OPEN_CLOSE_WINDOW_PIN/value
				OPEN_HELP=1
				CLOSE_HELP=1
                        fi


		else
			IS_WINDOW_CLOSE=$(tail -n 1 /sys/class/gpio/gpio$KONTRAKTON_CLOSE_PIN/value)
                        if [[ $IS_WINDOW_CLOSE = 0 ]]; then
                                echo 0 > /sys/class/gpio/gpio$OPEN_CLOSE_WINDOW_PIN/value
                                echo 1 > /sys/class/gpio/gpio$MOVE_WINDOW_PIN/value
                                if [[ $CLOSE_HELP = 1 ]]; then
					echo "$(date) WszystkoOK Zamykanie okna" >> $ISE_DZIENNIK
                                	DATA_TO_FILE=($(date | tr -d ','))
                                	echo "${DATA_TO_FILE[1]} ${DATA_TO_FILE[2]} ${DATA_TO_FILE[3]}" >> $CHANGE_LIBRARY_DATA
                                	echo "${DATA_TO_FILE[4]}" >> $CHANGE_LIBRARY_HOUR
                                	echo "Zamykanie okna" >> $CHANGE_LIBRARY_OPERATION
                                	echo "Warunki w normie" >> $CHANGE_LIBRARY_REASON


                                	ISE_RECORDS=($(wc -l $ISE_DZIENNIK))
                                	if [[ $ISE_RECORDS -gt 5000 ]]; then
                                	        ISE_DIARY=$(tail +5000 $ISE_DZIENNIK)
                                	        echo "$ISE_DIARY" > $ISE_DZIENNIK
                                	fi

                                	RECORDS=($(wc -l $CHANGE_LIBRARY_OPERATION))
                                	if [[ $RECORDS -gt 15 ]]; then
                                	        CHANGES=$(tail +15 $CHANGE_LIBRARY_OPERATION)
                                	        echo "$CHANGES" > $CHANGE_LIBRARY_OPERATION
                                        	CHANGES=$(tail +15 $CHANGE_LIBRARY_REASON)
                                        	echo "$CHANGES" > $CHANGE_LIBRARY_REASON
                                        	CHANGES=$(tail +15 $CHANGE_LIBRARY_HOUR)
                                        	echo "$CHANGES" > $CHANGE_LIBRARY_HOUR
                                        	CHANGES=$(tail +15 $CHANGE_LIBRARY_DATA)
                                        	echo "$CHANGES" > $CHANGE_LIBRARY_DATA
                                	fi
					HELP_FOR_AUTOMAT_MODE=1
					CLOSE_HELP=0
				fi
                        else
                                A_LITTLE_MORE_TIME_TO_CLOSE=$(tail -n 1 /sys/class/gpio/gpio$MOVE_WINDOW_PIN/value)
                                if [[ $A_LITTLE_MORE_TIME_TO_CLOSE = 1 ]] && [[ $HELP_FOR_AUTOMAT_MODE = 1 ]]; then
                                        echo "DUUUPKAAAA"
                                        $(sleep 5)
                                        echo 0 > /sys/class/gpio/gpio$MOVE_WINDOW_PIN/value
                                        echo 0 > /sys/class/gpio/gpio$OPEN_CLOSE_WINDOW_PIN/value
                                        HELP_FOR_AUTOMAT_MODE=0
					OPEN_HELP=1
					CLOSE_HELP=1
                                fi
                        fi
		fi








	elif [[ $MODE = 2 ]]; then #tryb manualny
		echo "manual"
		MANUAL_PROCES=$(tail -n 1 $MANUAL_PROCES_FILE)
		if [[ $MANUAL_PROCES = 1 ]]; then
			IS_WINDOW_OPEN=$(tail -n 1 /sys/class/gpio/gpio$KONTRAKTON_OPEN_PIN/value)
			if [[ $IS_WINDOW_OPEN = 0 ]]; then
				echo 1 > /sys/class/gpio/gpio$OPEN_CLOSE_WINDOW_PIN/value
				echo 1 > /sys/class/gpio/gpio$MOVE_WINDOW_PIN/value
				if [[ $OPEN_HELP = 1 ]]; then
					echo "$(date) MM Otwieranie okna" >> $ISE_DZIENNIK
					DATA_TO_FILE=($(date | tr -d ','))
					echo "${DATA_TO_FILE[1]} ${DATA_TO_FILE[2]} ${DATA_TO_FILE[3]}" >> $CHANGE_LIBRARY_DATA
					echo "${DATA_TO_FILE[4]}" >> $CHANGE_LIBRARY_HOUR
					echo "Otwieranie okna" >> $CHANGE_LIBRARY_OPERATION
					echo "Tryb manualny" >> $CHANGE_LIBRARY_REASON

					ISE_RECORDS=($(wc -l $ISE_DZIENNIK))
		                	if [[ $ISE_RECORDS -gt 5000 ]]; then
                				ISE_DIARY=$(tail +5000 $ISE_DZIENNIK)
         		        	        echo "$ISE_DIARY" > $ISE_DZIENNIK
                			fi

					RECORDS=($(wc -l $CHANGE_LIBRARY_OPERATION))
                                	if [[ $RECORDS -gt 15 ]]; then
                                		CHANGES=$(tail +15 $CHANGE_LIBRARY_OPERATION)
                                		echo "$CHANGES" > $CHANGE_LIBRARY_OPERATION
						CHANGES=$(tail +15 $CHANGE_LIBRARY_REASON)
                                        	echo "$CHANGES" > $CHANGE_LIBRARY_REASON
						CHANGES=$(tail +15 $CHANGE_LIBRARY_HOUR)
                                        	echo "$CHANGES" > $CHANGE_LIBRARY_HOUR
						CHANGES=$(tail +15 $CHANGE_LIBRARY_DATA)
                                        	echo "$CHANGES" > $CHANGE_LIBRARY_DATA
                                	fi
					OPEN_HELP=0
				fi
			else
				echo 0 > /sys/class/gpio/gpio$MOVE_WINDOW_PIN/value
                                echo 0 > /sys/class/gpio/gpio$OPEN_CLOSE_WINDOW_PIN/value
				echo "0" > $MANUAL_PROCES_FILE
				OPEN_HELP=1
				CLOSE_HELP=1
			fi

			HELP_FOR_AUTOMAT_MODE=1

		elif [[ $MANUAL_PROCES = 2 ]]; then
			IS_WINDOW_CLOSE=$(tail -n 1 /sys/class/gpio/gpio$KONTRAKTON_CLOSE_PIN/value)
			if [[ $IS_WINDOW_CLOSE = 0 ]]; then
				echo 0 > /sys/class/gpio/gpio$OPEN_CLOSE_WINDOW_PIN/value
				echo 1 > /sys/class/gpio/gpio$MOVE_WINDOW_PIN/value
                                if [[ $CLOSE_HELP = 1 ]]; then
					echo "$(date) MM Zamykanie okna" >> $ISE_DZIENNIK
                                	DATA_TO_FILE=($(date | tr -d ','))
                                	echo "${DATA_TO_FILE[1]} ${DATA_TO_FILE[2]} ${DATA_TO_FILE[3]}" >> $CHANGE_LIBRARY_DATA
                                	echo "${DATA_TO_FILE[4]}" >> $CHANGE_LIBRARY_HOUR
                                	echo "Zamykanie okna" >> $CHANGE_LIBRARY_OPERATION
                                	echo "Tryb manualny" >> $CHANGE_LIBRARY_REASON


					ISE_RECORDS=($(wc -l $ISE_DZIENNIK))
                                	if [[ $ISE_RECORDS -gt 5000 ]]; then
                                        	ISE_DIARY=$(tail +5000 $ISE_DZIENNIK)
                                        	echo "$ISE_DIARY" > $ISE_DZIENNIK
                                	fi

                                	RECORDS=($(wc -l $CHANGE_LIBRARY_OPERATION))
                                	if [[ $RECORDS -gt 15 ]]; then
                                        	CHANGES=$(tail +15 $CHANGE_LIBRARY_OPERATION)
                                        	echo "$CHANGES" > $CHANGE_LIBRARY_OPERATION
                                        	CHANGES=$(tail +15 $CHANGE_LIBRARY_REASON)
                                        	echo "$CHANGES" > $CHANGE_LIBRARY_REASON
                                        	CHANGES=$(tail +15 $CHANGE_LIBRARY_HOUR)
                                        	echo "$CHANGES" > $CHANGE_LIBRARY_HOUR
                                        	CHANGES=$(tail +15 $CHANGE_LIBRARY_DATA)
                                        	echo "$CHANGES" > $CHANGE_LIBRARY_DATA
                                	fi
					CLOSE_HELP=0
				fi

			else
				A_LITTLE_MORE_TIME_TO_CLOSE=$(tail -n 1 /sys/class/gpio/gpio$MOVE_WINDOW_PIN/value)
				if [[ $A_LITTLE_MORE_TIME_TO_CLOSE = 1 ]]; then
					echo "DUUUPAAAA"
					$(sleep 5)
					echo 0 > /sys/class/gpio/gpio$MOVE_WINDOW_PIN/value
					echo 0 > /sys/class/gpio/gpio$OPEN_CLOSE_WINDOW_PIN/value
					echo "0" > $MANUAL_PROCES_FILE
					CLOSE_HELP=1
					OPEN_HELP=1

				fi
			fi
		fi
	fi



done #pętla while 1 ta zapewniająca powtarzanie programu
