create or replace package body payment_detail_api_pack is
  /*
  Автор: Костина Екатерина
  Описание: API для сущностей “Детали платежа” 
  */
  -- Добавление или обновление данных платежа
  procedure insert_or_update_payment_detail (p_payment_id payment.payment_id%type,
                                             p_payment_detail t_payment_detail_array)
  is
    v_message varchar2(200 char) := 'Данные платежа добавлены или обновлены по списку id_поля/значение';
    v_current_dtime timestamp := systimestamp;
  begin
    if p_payment_id is null then
      dbms_output.put_line (c_error_msg_empty_object_id);
    end if;
    
    if p_payment_detail is not empty then
    
      for i in p_payment_detail.first..p_payment_detail.last loop 
    
        if (p_payment_detail(i).field_id is null) then
<<<<<<< HEAD
          raise_application_error(c_error_code_invalid_input_parameter, c_error_msg_empty_field_id);
        end if;
    
        if (p_payment_detail(i).field_value is null) then
          raise_application_error(c_error_code_invalid_input_parameter, c_error_msg_empty_field_value);
=======
          dbms_output.put_line (c_error_msg_empty_field_id);
        end if;
    
        if (p_payment_detail(i).field_value is null) then
          dbms_output.put_line (c_error_msg_empty_field_value);
>>>>>>> 1c30154d0c829ed1ff94ff70e3293f5d7a07ccf1
        end if;
       
      end loop;
     
    else
      dbms_output.put_line (c_error_msg_empty_collection);
    end if;
    
    dbms_output.put_line (v_message || '. ID: ' || p_payment_id);
    dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss.ff'));
   
    merge into payment_detail pd 
    using (select p_payment_id payment_id,
                  value(p).field_id field_id,
                  value(p).field_value field_value
           from table(p_payment_detail) p ) n
      on (pd.payment_id = n.payment_id and pd.field_id = n.field_id)
    when matched then 
      update set pd.field_value = n.field_value
    when not matched then 
      insert (payment_id,field_id,field_value)
      values (n.payment_id, n.field_id, n.field_value);
                  
  end;
  
  -- Удаление деталей платежа
  procedure delete_payment_detail (p_payment_id payment.payment_id%type,
                                   p_delete_detail_ids t_number_array)
  is
    v_message varchar2(200 char) := 'Детали платежа удалены по списку id_полей';
    v_current_dtime timestamp := systimestamp;
  begin
    if p_payment_id is null then
<<<<<<< HEAD
      raise_application_error(c_error_code_invalid_input_parameter, c_error_msg_empty_object_id);
    end if;
  
    if p_delete_detail_ids is empty then
      raise_application_error(c_error_code_invalid_input_parameter, c_error_msg_empty_collection);
=======
      dbms_output.put_line (c_error_msg_empty_object_id);
    end if;
  
    if p_delete_detail_ids is empty then
      dbms_output.put_line (c_error_msg_empty_collection);
>>>>>>> 1c30154d0c829ed1ff94ff70e3293f5d7a07ccf1
    end if;
    
    dbms_output.put_line (v_message || '. ID: ' || p_payment_id);
    dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss.ff'));
    dbms_output.put_line ('Количество полей для удаления: ' || p_delete_detail_ids.count());
   
    --удаление деталей платежа
    delete payment_detail pd
    where pd.payment_id = p_payment_id 
      and pd.field_id in (select value(t) 
                          from table (p_delete_detail_ids) t);
  end delete_payment_detail;

end payment_detail_api_pack;
/