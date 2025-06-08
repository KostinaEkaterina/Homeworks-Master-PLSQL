CREATE OR REPLACE package body PLSQL14_STUDENT5.payment_detail_api_pack is
  /*
  Автор: Костина Екатерина
  Описание: API для сущностей “Детали платежа” 
  */
  -- признак, выполняется ли изменение через API
  g_is_api boolean := false;
 
  -- разрешение менять данные
  procedure allow_changes is
  begin
	  g_is_api := true;
	end;
  
  -- запрещаем менять данные
  procedure disallow_changes is
  begin
	  g_is_api := false;
	end;

  -- Добавление или обновление данных платежа
  procedure insert_or_update_payment_detail (p_payment_id payment.payment_id%type,
                                             p_payment_detail t_payment_detail_array)
  is
  begin
    if p_payment_id is null then
      raise_application_error(common_pack.c_error_code_empty_object_id, common_pack.c_error_msg_empty_object_id);
    end if;
    
    if p_payment_detail is not empty then
    
      for i in p_payment_detail.first..p_payment_detail.last loop 
    
        if (p_payment_detail(i).field_id is null) then
          raise_application_error(common_pack.c_error_code_invalid_input_parameter, common_pack.c_error_msg_empty_field_id);
        end if;
    
        if (p_payment_detail(i).field_value is null) then
          raise_application_error(common_pack.c_error_code_invalid_input_parameter, common_pack.c_error_msg_empty_field_value);
        end if;
       
      end loop;
     
    else
      raise_application_error(common_pack.c_error_code_empty_collection, common_pack.c_error_msg_empty_collection);
    end if;
   
    allow_changes();
   
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
     
    disallow_changes();
  exception
    when others then
      disallow_changes();
      raise;
  end insert_or_update_payment_detail;
  
  -- Удаление деталей платежа
  procedure delete_payment_detail (p_payment_id payment.payment_id%type,
                                   p_delete_detail_ids t_number_array)
  is
  begin
    if p_payment_id is null then
      raise_application_error(common_pack.c_error_code_invalid_input_parameter, common_pack.c_error_msg_empty_object_id);
    end if;
  
    if p_delete_detail_ids is empty then
      raise_application_error(common_pack.c_error_code_invalid_input_parameter, common_pack.c_error_msg_empty_collection);
    end if;
   
    allow_changes();
   
    --удаление деталей платежа
    delete payment_detail pd
    where pd.payment_id = p_payment_id 
      and pd.field_id in (select value(t) 
                          from table (p_delete_detail_ids) t);
    disallow_changes();
   
  exception
    when others then
      disallow_changes();
      raise;
     
  end delete_payment_detail;
 
  -- проверка, вызываемая из триггера
  procedure is_changes_through_api
  is
  begin
    if not g_is_api and not common_pack.is_manual_changes_allowed then
      raise_application_error(common_pack.c_error_code_manual_changes, common_pack.c_error_msg_manual_changes);
    end if;
  end is_changes_through_api;
 
end payment_detail_api_pack;
/