  CREATE TABLE "MTL_CITY" 
   (	"ID" NUMBER, 
	"CITY" VARCHAR2(255), 
	"STATE_ID" NUMBER, 
	"COUNTRY_ID" NUMBER, 
	 CONSTRAINT "MTL_CITY_PK" PRIMARY KEY ("ID")
  USING INDEX  ENABLE
   ) ;

  CREATE TABLE "MTL_ROLE" 
   (	"ROLE_ID" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  NOT NULL ENABLE, 
	"ROLE_NAME" VARCHAR2(255 CHAR) NOT NULL ENABLE, 
	"ROLE_DESC" VARCHAR2(1000 CHAR), 
	 CONSTRAINT "MTL_ROLE_PK" PRIMARY KEY ("ROLE_ID")
  USING INDEX  ENABLE
   ) ;

  CREATE TABLE "MTL_USER" 
   (	"USER_ID" NUMBER NOT NULL ENABLE, 
	"EMAIL" VARCHAR2(255), 
	"PASSWORD" VARCHAR2(2000), 
	"VERIFICATION_CODE" VARCHAR2(255), 
	"ROLE_ID" NUMBER, 
	"REFER_URL" VARCHAR2(1000), 
	"REFER_USER_ID" NUMBER, 
	"POINTS" NUMBER, 
	"FIRST_NAME" VARCHAR2(100), 
	"LAST_NAME" VARCHAR2(100), 
	"ADDRESS1" VARCHAR2(255), 
	"ADDRESS2" VARCHAR2(255), 
	"CITY" VARCHAR2(100), 
	"STATEZIP" VARCHAR2(100), 
	 CONSTRAINT "MTL_USER_PK" PRIMARY KEY ("USER_ID")
  USING INDEX  ENABLE
   ) ;

  CREATE OR REPLACE EDITIONABLE TRIGGER "BI_MTL_CITY" 
  before insert on "MTL_CITY"               
  for each row  
begin   
  if :NEW."ID" is null then 
    select "MTL_CITY_SEQ".nextval into :NEW."ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER "BI_MTL_CITY" ENABLE;

  ALTER TABLE "MTL_USER" ADD CONSTRAINT "MTL_USER_FK" FOREIGN KEY ("ROLE_ID")
	  REFERENCES "MTL_ROLE" ("ROLE_ID") ENABLE;

  CREATE OR REPLACE EDITIONABLE TRIGGER "BI_MTL_USER" 
  before insert on "MTL_USER"               
  for each row  
begin   
  if :NEW."USER_ID" is null then 
    select "MTL_USER_SEQ".nextval into :NEW."USER_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER "BI_MTL_USER" ENABLE;












  CREATE UNIQUE INDEX "MTL_CITY_PK" ON "MTL_CITY" ("ID") 
  ;

  CREATE UNIQUE INDEX "MTL_ROLE_PK" ON "MTL_ROLE" ("ROLE_ID") 
  ;

  CREATE UNIQUE INDEX "MTL_USER_PK" ON "MTL_USER" ("USER_ID") 
  ;



create or replace package MTL_AUTH_PKG as

function custom_authenticate 
  ( 
    p_username in varchar2, 
    p_password in varchar2 
  ) 
  return boolean; 

procedure create_account( 
    p_email    in varchar2, 
    p_password in varchar2);


function verify_reset_password( 
    p_id in number, 
    p_verification_code in varchar2) 
  return number; 

 procedure request_reset_password( 
    p_email in varchar2) ;


 procedure mail_reset_password( 
  p_email    in varchar2, 
  p_url      in varchar2) ;
  
 procedure reset_password( 
    p_id       in number, 
    p_password in varchar2) ;

 function authz_administrator( 
    p_username in varchar2) 
  return boolean ;

 function authz_user( 
    p_username in varchar2) 
  return boolean ;
end;
/



















   CREATE SEQUENCE  "MTL_CITY_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 41 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;

   CREATE SEQUENCE  "MTL_USER_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 681 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;










create or replace trigger "BI_MTL_CITY"   
  before insert on "MTL_CITY"               
  for each row  
begin   
  if :NEW."ID" is null then 
    select "MTL_CITY_SEQ".nextval into :NEW."ID" from sys.dual; 
  end if; 
end; 
/
create or replace trigger "BI_MTL_USER"   
  before insert on "MTL_USER"               
  for each row  
begin   
  if :NEW."USER_ID" is null then 
    select "MTL_USER_SEQ".nextval into :NEW."USER_ID" from sys.dual; 
  end if; 
end; 
/

  CREATE OR REPLACE EDITIONABLE TRIGGER "BI_MTL_CITY" 
  before insert on "MTL_CITY"               
  for each row  
begin   
  if :NEW."ID" is null then 
    select "MTL_CITY_SEQ".nextval into :NEW."ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER "BI_MTL_CITY" ENABLE;

  CREATE OR REPLACE EDITIONABLE TRIGGER "BI_MTL_USER" 
  before insert on "MTL_USER"               
  for each row  
begin   
  if :NEW."USER_ID" is null then 
    select "MTL_USER_SEQ".nextval into :NEW."USER_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER "BI_MTL_USER" ENABLE;













  CREATE UNIQUE INDEX "MTL_CITY_PK" ON "MTL_CITY" ("ID") 
  ;

  CREATE OR REPLACE EDITIONABLE TRIGGER "BI_MTL_CITY" 
  before insert on "MTL_CITY"               
  for each row  
begin   
  if :NEW."ID" is null then 
    select "MTL_CITY_SEQ".nextval into :NEW."ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER "BI_MTL_CITY" ENABLE;

  CREATE UNIQUE INDEX "MTL_ROLE_PK" ON "MTL_ROLE" ("ROLE_ID") 
  ;

  CREATE UNIQUE INDEX "MTL_USER_PK" ON "MTL_USER" ("USER_ID") 
  ;

  CREATE OR REPLACE EDITIONABLE TRIGGER "BI_MTL_USER" 
  before insert on "MTL_USER"               
  for each row  
begin   
  if :NEW."USER_ID" is null then 
    select "MTL_USER_SEQ".nextval into :NEW."USER_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER "BI_MTL_USER" ENABLE;



create or replace package body mtl_auth_pkg 
as 
 
/** 
* Constants 
*/ 
 
 
c_from_email constant varchar2(100) := 'no-reply@my.email'; 
c_website    constant varchar2(100) := 'my site'; 
c_hostname   constant varchar2(100) := 'apex.oracle.com/pls/apex/'; 

/**  Log in the application  
 */ 
function custom_authenticate 
  ( 
    p_username in varchar2, 
    p_password in varchar2 
  ) 
  return boolean 
is 
  l_password        varchar2(100) ; 
  l_stored_password varchar2(100) ; 
  l_boolean         boolean; 
begin 
  -- First, check to see if the user is in the user table and look up their password 
  select password 
    into l_stored_password 
    from mtl_user 
   where upper(email) = upper(p_username); 
  -- hash the password the person entered 
   select standard_hash(p_password, 'MD5') into l_password from dual;
  -- Finally, we compare them to see if they are the same and return either TRUE or FALSE 
 if l_password = l_stored_password then 
    return true; 
  else 
    return false; 
  end if; 
exception 
when no_data_found then 
  return false; 
end custom_authenticate;  


/**  Register 
*/ 
procedure create_account( 
    p_email    in varchar2, 
    p_password in varchar2) 
is 
  l_message varchar2(4000) ; 
  l_password raw(64) ; 
  l_user_id number; 
  l_url  varchar2(1000) ; 
begin 
  apex_debug.message(p_message => 'Begin create_site_account', p_level => 3); 
 
 -- l_password := utl_raw.cast_to_raw(DBMS_RANDOM.string('x',10)); 
 select standard_hash(p_password, 'MD5') into l_password from dual;
 
  apex_debug.message(p_message => 'verify email exists', p_level => 3) ; 
 
  begin 
    select password 
      into l_password 
      from mtl_user 
     where upper(email) = upper(p_email) ; 
    l_message       := l_message || 'Email address already registered.'; 
 
  exception 
  when no_data_found then 
    apex_debug.message(p_message => 'email doesn''t exist yet - good to go', p_level => 3) ; 
  end; 
 
  if l_message is null then 
    apex_debug.message(p_message => 'password ok', p_level => 3) ; 
  
    apex_debug.message(p_message => 'insert record', p_level => 3) ; 
    /* insert return user_id *****/ 
    insert into mtl_user (email, password,role_id) 
    values (p_email, l_password,2)  
    returning USER_ID into l_user_id; 
   
    -- create refer url   
    l_url := c_hostname||'f?p='||v('APP_ID')||':9999:0::::p9999_refer_user_id:' || l_user_id ;
    
    apex_debug.message(p_message => 'update record', p_level => 3) ; 
    
    update mtl_user
    set refer_url=l_url
    where user_id=l_user_id;

  else 
    raise_application_error( -20001, l_message) ; 
  end if; 
   
 -- apex_authentication.post_login(p_username => p_email, p_password => p_password); 
 
  -- no activation email 
  
  --  :refer_user_id := 1;
 
  apex_debug.message(p_message => 'End create_site_account', p_level => 3) ; 
end create_account; 
 
/** 
*/ 
procedure post_authenticate( 
    p_username in varchar2, 
    out_user_id out number, 
    out_time_zone out varchar2 
) 
is 
  l_id         number; 
  l_first_name varchar2(100) ; 
begin 
  select USER_ID 
    into l_id 
    from mtl_user 
   where upper(email)    = upper(p_username); 
  out_user_id        := l_id; 
 
end post_authenticate; 
 
 
/** 
*/ 
procedure request_reset_password( 
    p_email in varchar2) 
is 
  l_id                number; 
  l_verification_code varchar2(100); 
  l_url               varchar2(200); 
begin 
  -- First, check to see if the user is in the user table 
  select USER_ID 
    into l_id 
    from mtl_user 
   where upper(email)    = upper(p_email); 
 
  dbms_random.initialize(to_char(sysdate, 'YYMMDDDSS')) ; 
  l_verification_code := dbms_random.string('A', 20); 
 
  l_url := apex_util.prepare_url(p_url => c_hostname||'f?p='||v('APP_ID')||':31:0::::P31_USER_ID,P31_VC:' || l_id || ',' || l_verification_code, p_checksum_type => 1); 
   
  update mtl_user 
    set verification_code = 'RESET_' || l_verification_code 
  where user_id = l_id; 
 
  mail_reset_password(p_email => p_email, p_url => l_url); 
 
exception 
when no_data_found then 
  raise_application_error( - 20001, 'Email address not registered.') ; 
end request_reset_password ; 
 
 /** 
* Reset password email 
*/ 
procedure mail_reset_password( 
  p_email    in varchar2, 
  p_url      in varchar2) 
is 
  l_body     clob;   
begin 
  apex_debug.message(p_message => 'Reset password demo account', p_level => 3) ;   
  l_body := '<p>Hi,</p> 
             <p>We received a request to reset your password in the training app.</p> 
             <p><a href="'||p_url||'">Reset Now.</a></p> 
             <p>If you did not request this, you can simply ignore this email.</p> 
             <p>Kind regards,<br/> 
             The Training Team</p>'; 
 
  apex_mail.send ( 
    p_to        => p_email, 
    p_from      => c_from_email, 
    p_body      => l_body, 
    p_body_html => l_body, 
    p_subj      => 'Reset password demo account'); 
 
  apex_mail.push_queue;     
 
exception 
when others  
then 
  raise_application_error( - 20002, 'Issue sending reset password email.') ; 
end mail_reset_password; 


/** Reset Password
*/ 
procedure reset_password( 
    p_id       in number, 
    p_password in varchar2) 
is 
  l_username        varchar2(100) ; 
  l_hashed_password varchar2(100) ; 
begin 
  select email 
    into l_username 
    from mtl_user 
   where USER_ID = p_id; 
 
  select standard_hash(p_password, 'MD5') into l_hashed_password from dual;
 
  update mtl_user 
    set password = l_hashed_password, 
        verification_code = null 
  where USER_ID = p_id; 
end reset_password; 

/** Check the verification code
*/ 
function verify_reset_password( 
    p_id in number, 
    p_verification_code in varchar2) 
  return number 
is 
  l_id number; 
begin 
  begin
  select u.USER_ID 
    into l_id 
    from mtl_user u 
   where u.verification_code = 'RESET_'||p_verification_code 
     and u.USER_ID = p_id; 
 
  return l_id; 
exception 
  when no_data_found 
  then 
    raise_application_error( - 20001, 'Invalid password request url.') ; 
    l_id:=0;
    return 0; 
 end;
 return  l_id;
end verify_reset_password ; 
 
 

 
 
/** check the user is the administrator
*/ 
function authz_administrator( 
    p_username in varchar2) 
  return boolean 
is 
  l_is_admin varchar2(1) ; 
begin 
  select 'Y' 
    into l_is_admin 
    from mtl_user a 
   where upper(a.email) = upper(p_username) 
     and a.role_id = 1; 
  -- 
  return true; 
exception 
when no_data_found then 
  return false; 
end authz_administrator; 
 
 
/** check the username is the account username
*/ 
function authz_user( 
    p_username in varchar2) 
  return boolean 
is 
  l_is_user varchar2(1) ; 
begin 
  select 'Y' 
    into l_is_user 
    from mtl_user a 
   where upper(a.email) = upper(p_username) 
     and a.role_id in (1,2); 
  -- 
  return true; 
exception 
when no_data_found then 
  return false; 
end authz_user; 
 
end mtl_auth_pkg;
/

















