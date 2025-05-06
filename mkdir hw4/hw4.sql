/*
Автор: Костина Екатерина
Описание скрипта: API для сущностей “Платеж” и “Детали платежа”
*/

-- Создание платежа
declare
  v_payment_id  payment.payment_id%type;
  v_message varchar2(200 char) := 'Платеж создан';
  c_new_status constant payment.status%type := 0;
  v_current_dtime date := sysdate;
  v_summa payment.summa%type := 5000;
  v_currency_id payment.currency_id%type := 643;
  v_from_client_id payment.from_client_id%type := 1;
  v_to_client_id payment.to_client_id%type := 2;
  v_payment_detail t_payment_detail_array:= t_payment_detail_array(t_payment_detail(1,'Тестовый софт'),
                                                                   t_payment_detail(2,'66.250.68.32'),
                                                                   t_payment_detail(3,'Создание'));
begin
  
  if v_payment_detail is not empty then
  
    for i in v_payment_detail.first..v_payment_detail.last loop 
	
      if (v_payment_detail(i).field_id is null) then
        dbms_output.put_line ('ID поля не может быть пустым');
      end if;
	
      if (v_payment_detail(i).field_value is null) then
        dbms_output.put_line ('Значение в поле не может быть пустым');
      end if;
		 
    end loop;
   
  else
    dbms_output.put_line ('Коллекция не содержит данных');
  end if;
  
  dbms_output.put_line (v_message || '. Статус: ' || c_new_status || '. ID: ' || v_payment_id);
  dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss'));
 
  --создание платежа
  insert into payment (payment_id, create_dtime, summa,currency_id,from_client_id,to_client_id)
  values (payment_seq.nextval, v_current_dtime, v_summa, v_currency_id,  v_from_client_id,v_to_client_id)
  returning payment_id into v_payment_id;
 
  dbms_output.put_line ('Создан новый payment: ' || v_payment_id);
 
  --добавление данных о платеже
 
  insert into payment_detail (payment_id, field_id, field_value)
  select v_payment_id, value(p).field_id, value(p).field_value
  from table(v_payment_detail) p;
 
end;
/
-- Перевод платежа в ошибочный статус с описанием причины
declare
  v_payment_id  payment.payment_id%type := 13;
  v_message varchar2(200 char) := 'Сброс платежа в "ошибочный статус" с указанием причины';
  v_reason payment.status_change_reason%type := 'недостаточно средств';
  c_error_status constant payment.status%type := 2;
  v_current_dtime date := sysdate;
  v_current_status payment.status%type;
begin
  if v_payment_id is null then
    dbms_output.put_line ('ID объекта не может быть пустым');
  end if;
  
  if v_reason is null then
    dbms_output.put_line ('Причина не может быть пустой');
  end if;
  
  --найдем текущий статус платежа
  select p.status into v_current_status
  from payment p 
  where p.payment_id = v_payment_id;
 
  --если статус - создан, то производим обновление статуса
  if v_current_status = 0 then
    --обновление статуса платежа
    update payment p 
    set p.status = c_error_status,
        p.status_change_reason  = v_reason
    where p.payment_id = v_payment_id;
	 
    dbms_output.put_line (v_message || '. Статус: '|| c_error_status ||'. Причина: ' || v_reason || '. ID: ' || v_payment_id);
    dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss'));
  else 
    dbms_output.put_line ('Ошибка. Статус платежа не в статусе "Создан". ID платежа: ' || v_payment_id);
  end if;
 
end;
/
-- Отмена платежа
declare
  v_payment_id  payment.payment_id%type := 13;
  v_message varchar2(200 char) := 'Отмена платежа с указанием причины';
  v_reason payment.status_change_reason%type := 'ошибка пользователя';
  c_cancel_status constant payment.status%type := 3;
  v_current_dtime date := sysdate;
  v_current_status payment.status%type;
begin
  if v_payment_id is null then
    dbms_output.put_line ('ID объекта не может быть пустым');
  end if;
  
  if v_reason is null then
    dbms_output.put_line ('Причина не может быть пустой');
  end if;
 
  --найдем текущий статус платежа
  select p.status into v_current_status
  from payment p 
  where p.payment_id = v_payment_id;
 
  --если статус - создан, то производим обновление статуса
  if v_current_status = 0 then
    --обновление статуса платежа
    update payment p 
    set p.status = c_cancel_status,
        p.status_change_reason  = v_reason
    where p.payment_id = v_payment_id;
	 
    dbms_output.put_line (v_message || '. Статус: ' || c_cancel_status|| '. Причина: ' || v_reason || '. ID: ' || v_payment_id);
    dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss'));
  else 
    dbms_output.put_line ('Ошибка. Статус платежа не в статусе "Создан". ID платежа: ' || v_payment_id);
  end if;
end;
/
-- Завершение платежа
declare
  v_payment_id  payment.payment_id%type:= 13;
  v_message varchar2(200 char) := 'Успешное завершение платежа';
  c_success_status constant payment.status%type := 1;
  v_current_dtime date := sysdate;
  v_current_status payment.status%type;
begin
  if v_payment_id is null then
    dbms_output.put_line ('ID объекта не может быть пустым');
  end if;
 
  --найдем текущий статус платежа
  select p.status into v_current_status
  from payment p 
  where p.payment_id = v_payment_id;
 
  --если статус - создан, то производим обновление статуса
  if v_current_status = 0 then
    --обновление статуса платежа
    update payment p 
    set p.status = c_success_status
    where p.payment_id = v_payment_id;
	 
    dbms_output.put_line (v_message || '. Статус: ' || c_success_status);
    dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss'));
  else 
    dbms_output.put_line ('Ошибка. Статус платежа не в статусе "Создан". ID платежа: ' || v_payment_id);
  end if;
end;
/
-- Добавление или обновление данных платежа
declare
  v_payment_id  payment.payment_id%type := 13;
  v_message varchar2(200 char) := 'Данные платежа добавлены или обновлены по списку id_поля/значение';
  v_current_dtime timestamp := systimestamp;
  v_payment_detail t_payment_detail_array:= t_payment_detail_array(t_payment_detail(2,'66.250.68.32'),
                                                                   t_payment_detail(3,'Обновление'));
begin
  if v_payment_id is null then
    dbms_output.put_line ('ID объекта не может быть пустым');
  end if;
  
  if v_payment_detail is not empty then
  
    for i in v_payment_detail.first..v_payment_detail.last loop 
	
      if (v_payment_detail(i).field_id is null) then
        dbms_output.put_line ('ID поля не может быть пустым');
      end if;
	
      if (v_payment_detail(i).field_value is null) then
        dbms_output.put_line ('Значение в поле не может быть пустым');
      end if;
		 
    end loop;
   
  else
    dbms_output.put_line ('Коллекция не содержит данных');
  end if;
  
  dbms_output.put_line (v_message || '. ID: ' || v_payment_id);
  dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss.ff'));
 
  merge into payment_detail pd 
  using (select v_payment_id payment_id,
                value(p).field_id field_id,
                value(p).field_value field_value
         from table(v_payment_detail) p ) n
  	on (pd.payment_id = n.payment_id and pd.field_id = n.field_id)
  when matched then 
    update set pd.field_value = n.field_value
  when not matched then 
    insert (payment_id,field_id,field_value)
    values (n.payment_id, n.field_id, n.field_value);
  							
end;
/
-- Удаление деталей платежа
declare
  v_payment_id  payment.payment_id%type := 13;
  v_message varchar2(200 char) := 'Детали платежа удалены по списку id_полей';
  v_current_dtime timestamp := systimestamp;
  v_delete_detail_ids t_number_array:= t_number_array(1,3);
begin
  if v_payment_id is null then
    dbms_output.put_line ('ID объекта не может быть пустым');
  end if;

  if v_delete_detail_ids is empty then
    dbms_output.put_line ('Коллекция не содержит данных');
  end if;
  
  dbms_output.put_line (v_message || '. ID: ' || v_payment_id);
  dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss.ff'));
  dbms_output.put_line ('Количество полей для удаления: ' || v_delete_detail_ids.count());
 
  --удаление деталей платежа
  delete payment_detail pd
  where pd.payment_id = v_payment_id 
    and pd.field_id in (select value(t) 
                        from table (v_delete_detail_ids) t);
end;
/