create or replace package body payment_api_pack is
  /*
  Автор: Костина Екатерина
  Описание скрипта: API для сущностей “Платеж”
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

  -- создание платежа
  function create_payment (p_from_client_id payment.from_client_id%type,
                           p_to_client_id payment.to_client_id%type,
                           p_summa payment.summa%type,
                           p_currency_id payment.currency_id%type,
                           p_create_dtime payment.create_dtime%type,
                           p_payment_detail t_payment_detail_array) return payment.payment_id%type
  is
    v_payment_id  payment.payment_id%type;
    v_message varchar2(200 char) := 'Платеж создан'; 
  begin
    
    if p_payment_detail is not empty then
    
      for i in p_payment_detail.first..p_payment_detail.last loop 
    
        if (p_payment_detail(i).field_id is null) then
         raise_application_error(c_error_code_invalid_input_parameter, c_error_msg_empty_field_id);
        end if;
    
        if (p_payment_detail(i).field_value is null) then
          raise_application_error(c_error_code_invalid_input_parameter, c_error_msg_empty_field_value);
        end if;
       
      end loop;
     
    else
      raise_application_error(c_error_code_invalid_input_parameter,c_error_msg_empty_collection);
    end if;
    
    dbms_output.put_line (v_message || '. Статус: ' || c_new_status || '. ID: ' || v_payment_id);
    dbms_output.put_line (to_char(p_create_dtime,'dd.mm.yyyy hh24:mm:ss'));
   
    allow_changes();
   
    --создание платежа
    insert into payment (payment_id, create_dtime, summa,currency_id,from_client_id,to_client_id)
    values (payment_seq.nextval, p_create_dtime, p_summa, p_currency_id,  p_from_client_id,p_to_client_id)
    returning payment_id into v_payment_id;
   
    dbms_output.put_line ('Создан новый payment: ' || v_payment_id);
   
    --добавление данных о платеже
    payment_detail_api_pack.insert_or_update_payment_detail (v_payment_id, p_payment_detail);
   
    disallow_changes();
   
    return v_payment_id;
   
  exception
    when others then
      disallow_changes();
      raise;
  end create_payment;
  
  -- Перевод платежа в ошибочный статус с описанием причины
  procedure fail_payment (p_payment_id payment.payment_id%type,
                          p_reason payment.status_change_reason%type)
  is
    v_message varchar2(200 char) := 'Сброс платежа в "ошибочный статус" с указанием причины';
    v_current_dtime date := sysdate;
  begin
    if p_payment_id is null then
      raise_application_error(c_error_code_invalid_input_parameter, c_error_msg_empty_object_id);
    end if;
    
    if p_reason is null then
      raise_application_error(c_error_code_invalid_input_parameter, c_error_msg_empty_reason);
    end if;
   
    allow_changes();
   
    --обновление статуса платежа
    update payment p 
    set p.status = c_error_status,
        p.status_change_reason  = p_reason
    where p.payment_id = p_payment_id
      and p.status = 0; 
     
    disallow_changes();
   
    --если было произвенено обновление, выводим информацию
    if sql%rowcount > 0 then
      dbms_output.put_line (v_message || '. Статус: '|| c_error_status ||'. Причина: ' || p_reason || '. ID: ' || p_payment_id);
      dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss'));
    --если не было, то выводим информацию об ошибке
    else 
      raise_application_error(c_error_code_invalid_payment_status, c_error_msg_not_new_status || p_payment_id);
    end if;
   
   
  exception
    when others then
      disallow_changes();
      raise;
  end fail_payment;

  -- Отмена платежа
  procedure cancel_payment (p_payment_id  payment.payment_id%type,
                            p_reason payment.status_change_reason%type)
  is
    v_message varchar2(200 char) := 'Отмена платежа с указанием причины';
    v_current_dtime date := sysdate;
  begin
    if p_payment_id is null then
      raise_application_error(c_error_code_invalid_input_parameter, c_error_msg_empty_object_id);
    end if;
    
    if p_reason is null then
      raise_application_error(c_error_code_invalid_input_parameter, c_error_msg_empty_reason);
    end if;
   
    allow_changes();
   
    update payment p 
    set p.status = c_cancel_status,
        p.status_change_reason  = p_reason
    where p.payment_id = p_payment_id
      and p.status = 0;
     
    disallow_changes();
   
    --если было произвенено обновление, выводим информацию
    if sql%rowcount > 0 then
      dbms_output.put_line (v_message || '. Статус: ' || c_cancel_status|| '. Причина: ' || p_reason || '. ID: ' || p_payment_id);
      dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss'));
    --если не было, то выводим информацию об ошибке
    else 
      raise_application_error(c_error_code_invalid_payment_status, c_error_msg_not_new_status || p_payment_id);
    end if;
   
  exception
    when others then
      disallow_changes();
      raise;
  end cancel_payment;

  -- Завершение платежа
  procedure successful_finish_payment (p_payment_id payment.payment_id%type)
  is
    v_message varchar2(200 char) := 'Успешное завершение платежа';
    v_current_dtime date := sysdate;
  begin
    if p_payment_id is null then
      raise_application_error(c_error_code_invalid_input_parameter, c_error_msg_empty_object_id);
    end if;
   
    allow_changes();
   
    --обновление статуса платежа
    update payment p 
    set p.status = c_success_status
    where p.payment_id = p_payment_id
      and p.status = 0;
     
    disallow_changes();
   
    --если было произвенено обновление, выводим информацию
    if sql%rowcount > 0 then
      dbms_output.put_line (v_message || '. Статус: ' || c_success_status);
      dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss'));
    else 
      raise_application_error(c_error_code_invalid_payment_status, c_error_msg_not_new_status || p_payment_id);
    end if;
   
  exception
    when others then
      disallow_changes();
      raise;
  end successful_finish_payment;

  -- проверка, вызываемая из триггера
  procedure is_changes_through_api
  is
  begin
    if not g_is_api then
      raise_application_error(c_error_code_manual_changes, c_error_msg_manual_changes);
    end if;
  end is_changes_through_api;
 
end payment_api_pack;
/