﻿note
	description: "Clase che rappresenta lo stato della state chart"
	author: "Gabriele Cacchioni & Davide Canalis "
	date: "9-04-2015"
	revision: "0.1"

class
	STATO

create
	make_with_id, make_final_with_id, make_empty

feature --creazione

	make_with_id (un_id: STRING)
		require
			non_e_una_stringa_vuota: un_id /= Void
		do
			id := un_id
			finale := FALSE
			create transizioni.make_empty
		ensure
			attributo_assegnato: id = un_id
		end

	make_final_with_id (un_id: STRING)
		require
			non_e_una_stringa_vuota: un_id /= Void
		do
			id := un_id
			finale := TRUE
			create transizioni.make_empty
		ensure
			attributo_assegnato: id = un_id
		end

	make_empty
		do
			create transizioni.make_empty
			finale := false
			create id.make_empty
		end

feature --attributi

	transizioni: ARRAY [TRANSIZIONE]

	finale: BOOLEAN

	id: STRING

feature --setter

	set_final
		do
			finale := TRUE
		ensure
			ora_e_finale: finale
		end

		--add_transition

feature --routines

	aggiungi_transizione (tr: TRANSIZIONE)
		do
			transizioni.force (tr, transizioni.count + 1)
		end


	numero_transizioni_abilitate (evento_corrente: STRING; hash_delle_condizioni: HASH_TABLE [BOOLEAN, STRING]): INTEGER
			-- ritorna il numero di transizioni attivabili con evento_corrente nella configurazione corrente
		local
			index_count: INTEGER
			numero_di_transizioni_attivate_da_evento_corrente: INTEGER
		do
			from
				index_count := transizioni.lower
				numero_di_transizioni_attivate_da_evento_corrente := 0
			until
				index_count = transizioni.upper + 1 or numero_di_transizioni_attivate_da_evento_corrente > 1
			loop
				if attached evento_corrente as ec then if attivabile (index_count, ec, hash_delle_condizioni) then
					numero_di_transizioni_attivate_da_evento_corrente := numero_di_transizioni_attivate_da_evento_corrente + 1
				end
			end
				index_count := index_count + 1
			end

			Result := numero_di_transizioni_attivate_da_evento_corrente
		end

	attivabile (index_count: INTEGER; evento_corrente: STRING; hash_delle_condizioni: HASH_TABLE [BOOLEAN, STRING]): BOOLEAN
		do
			if attached transizioni [index_count].evento as e then
				if e.is_equal (evento_corrente) then
					if attached transizioni [index_count].condizione as c then
						if hash_delle_condizioni.item (c) = True then
							Result := True
						end
					end
				end
			else
				if attached transizioni [index_count].condizione as cond then
						if hash_delle_condizioni.item (cond) = True then
							Result := True
						end
				end
			end
		end

	target (evento_corrente: STRING; hash_delle_condizioni: HASH_TABLE [BOOLEAN, STRING]): detachable STATO
		-- ritorna Void se con evento_corrente nella configurazione corrente non è attivabile alcuna transizione
		-- ritorna lo stato a cui porta la transizione di indice massimoattivabile nella configurazione corrente con evento_corrente
		require
			numero_transizioni_abilitate (evento_corrente,hash_delle_condizioni)<2
		local
			target_della_transizione: detachable STATO
			index_count: INTEGER
		do
			target_della_transizione := Void
			from
				index_count := transizioni.lower
			until
				index_count = transizioni.upper + 1 or target_della_transizione /= Void
			loop
				if attached transizioni [index_count].evento as ang then
					if ang.is_equal (evento_corrente) then
						if attached transizioni [index_count].condizione as cond then
							if attached hash_delle_condizioni.item (cond) as cond_in_hash then
								if cond_in_hash = TRUE then
									target_della_transizione := transizioni [index_count].target
								end
							end
						end
					end
				end
				index_count := index_count + 1
			end
			result := target_della_transizione
		end


feature --cose a parte

	get_transition (evento_corrente: STRING): TRANSIZIONE
		local
			index_count: INTEGER
			index: INTEGER
		do
			from
				index_count := transizioni.lower
			until
				index_count = transizioni.upper + 1
			loop
				if attached transizioni [index_count].evento as te then
					if te.is_equal (evento_corrente) then
						index := index_count
					end
				end
				index_count := index_count + 1
			end
			Result := transizioni [index]
		end

end
