.386
.model flat,stdcall 
option casemap:none

include msvcrt.inc
includelib msvcrt.lib

.data
PERSON struct
	szName db 32 dup(0)
	szNumber db 32 dup(0)
PERSON ends

g_count DWORD 0;int count ;当前共有多少联系人
g_maxCount DWORD 100;int maxCount;最大能存多少
g_person PERSON 100 dup(<'0'>);PERSON g_book联系人数组
g_strTemPerson PERSON <'0','0'>;接收输入信息
g_pFile DWORD 0;文件指针
.const
szWelcom db "****Phone Note****",0Ah,
	"1.增",0Ah,"2.删",0Ah,
	"3.改",0Ah,"4.查",0Ah,
	"5.显示所有",0Ah,"6.退出",0Ah,0
szAddNote db "请输入姓名和手机号：",0Ah,0
szAddRes db "添加成功",0Ah,0
szCLS db "cls",0
szFromatC db "%c",0
szFromatD db "%d",0Ah,0
szFromatS db "%s",0
szFromatSS db "%s",09h,"%s",0Ah,0
szFormatT db 09h,0
szFormatN db 0Ah,0
szShowNote1 db "一共有%d条记录",0Ah,"------------------",0Ah,0
szFindNote db "请输入要查找的姓名：",0
szFindNote1 db 0Ah,"查找完毕",0Ah,0
szDelNote db "请输入要删除的姓名：",0
szDelNote1 db 0Ah,"删除完毕",0Ah,0
szAltNote db "请输入要修改的姓名：",0
szAltNote1 db 0Ah,"修改完毕",0Ah,0
szAltNote2 db 0Ah,"请输入新的号码：",0
szFileName db "phone.txt",0
szFileRead db "rb+",0
szFileWrite db "wb+",0
szFileFail db "打开文件失败",0
.code
mini proc
	push ebp
	mov ebp,esp
	invoke crt_fopen,offset szFileName,offset szFileRead
	push eax
	pop g_pFile
	cmp eax,0
	
	jne @OK
	invoke crt_printf,offset szFileFail
	call crt_getchar;getchar()
	invoke crt_exit,0
@OK:	
	lea edx,[g_count]
	invoke crt_fscanf,g_pFile,offset szFromatD,edx
	mov ebx,sizeof(PERSON)
	invoke crt_fread,offset g_person,ebx,100,g_pFile
	
	invoke crt_fclose,g_pFile
	mov esp,ebp
	pop ebp
	ret

mini endp
msave proc
	
	push ebp
	mov ebp,esp
	invoke crt_fopen,offset szFileName,offset szFileWrite
	push eax
	pop g_pFile
	cmp eax,0
	
	jne @OK
	invoke crt_printf,offset szFileFail
	call crt_getchar;getchar()
	invoke crt_exit,0
@OK:	
	invoke crt_fprintf,g_pFile,offset szFromatD,g_count
	mov ebx,sizeof(PERSON)
	invoke crt_fwrite,offset g_person,ebx,g_count,g_pFile
	
	invoke crt_fclose,g_pFile
	mov esp,ebp
	pop ebp
	ret

msave endp
madd proc
	push ebp
	mov ebp,esp
	
	push offset szAddNote;printf("请输入姓名电话")
	call crt_printf
	add esp,4
	lea esi,[g_person]
	mov ecx,g_count
	mov eax,sizeof(PERSON)
	imul eax,ecx
	add esi,eax
	
	lea eax,[esi+PERSON.szName]
	push eax
	push offset szFromatS
	call crt_scanf
	add esp,8
	lea eax,[esi+PERSON.szNumber]
	push eax
	push offset szFromatS
	call crt_scanf
	add esp,8
	mov ecx,g_count
	add g_count,1
	push offset szAddRes
	call crt_printf
	add esp,4
	
	mov esp,ebp
	pop ebp
	ret

madd endp
mshow proc
	push ebp
	mov ebp,esp
	
	mov ecx,g_count
	;printf("一共几条记录")
	invoke crt_printf,offset szShowNote1,g_count
	
	cmp g_count,0
	jne @f
	
	mov esp,ebp
	pop ebp
	ret
@@:
	xor ecx,ecx
_LOOP:
	push ecx
	lea esi,[g_person]
	mov eax,sizeof(PERSON)
	imul eax,ecx
	add esi,eax
	
	lea eax,[esi+PERSON.szNumber]
	push eax
	lea eax,[esi+PERSON.szName]
	push eax
	push offset szFromatSS
	call crt_printf 
	add esp,0Ch
	pop ecx
	
	inc ecx
	cmp ecx,g_count
	jne _LOOP
	
	mov esp,ebp
	pop ebp
	ret

mshow endp
mfind proc
	push ebp
	mov ebp,esp
	
	invoke crt_printf,offset szFindNote
	lea edi,[g_strTemPerson.szName]
	invoke crt_scanf,offset szFromatS,edi
	
	;开始查询
	xor ecx,ecx
	mov eax,[g_count]
CYCLE_MARK:
	cmp ecx,g_count
	
	je @END
	
	lea esi,[g_person]
	lea edi,[g_strTemPerson.szName]
	mov eax,sizeof(PERSON)
	imul eax,ecx
	add esi,eax
	;比较字符串
	mov eax,ecx;保护外层循环的次数
	mov ecx,8
	repe cmps dword ptr [esi],dword ptr [edi]
	je GOTIT;如果找到
	mov ecx,eax;如果没找到继续外层循环
	inc ecx
	jmp CYCLE_MARK
GOTIT:
	mov ecx,eax
	lea esi,[g_person]
	mov ebx,sizeof(PERSON)
	imul ebx,ecx
	add esi,ebx
	lea eax,[esi+PERSON.szNumber]
	invoke crt_printf,eax
	
	
@END:	
	invoke crt_printf,offset szFindNote1
	mov esp,ebp
	pop ebp
	ret

mfind endp
mdel proc
	push ebp
	mov ebp,esp
	invoke crt_printf,offset szDelNote
	lea edi,[g_strTemPerson.szName]
	invoke crt_scanf,offset szFromatS,edi
	
	;开始查询
	xor ecx,ecx
	mov eax,[g_count]
CYCLE_MARK:
	cmp ecx,g_count
	
	je @END
	
	lea esi,[g_person]
	lea edi,[g_strTemPerson.szName]
	mov eax,sizeof(PERSON)
	imul eax,ecx
	add esi,eax
	;比较字符串
	mov eax,ecx;保护外层循环的次数
	mov ecx,6
	repe cmps dword ptr [esi],dword ptr [edi]
	je GOTIT;如果找到
	mov ecx,eax;如果没找到继续外层循环
	inc ecx
	jmp CYCLE_MARK
GOTIT:
	mov ecx,eax
	lea esi,[g_person]
	mov ebx,sizeof(PERSON)
	imul ebx,ecx
	add esi,ebx;esi保存的是要删除的首地址
	push esi;保存esi
	push ecx;保存ecx
	lea eax,[esi+PERSON.szNumber]
	invoke crt_printf,eax
	pop ecx;恢复
	pop esi;恢复
	mov edi,esi;edi保存的也是要删除的首地址
	mov ebx,sizeof(PERSON)
	add esi,ebx;esi保存的是下一条
	
	add ecx,1
	
	mov eax,g_count
	sub eax,ecx;需要移动的次数
	mov ebx,sizeof(PERSON)
	imul ebx,eax
	mov ecx,ebx;计算需要移动的字节
	rep movs BYTE ptr [edi],BYTE ptr [esi];开始移动
	
	mov ebx,sizeof(PERSON)
	push ebx
	push 0
	push edi;删除的首地址
	call crt_memset
	add esp,12
	dec g_count
	
	
@END:	
	invoke crt_printf,offset szDelNote1
	mov esp,ebp
	pop ebp
	ret

mdel endp
malter proc
	push ebp
	mov ebp,esp
	invoke crt_printf,offset szAltNote
	lea edi,[g_strTemPerson.szName]
	invoke crt_scanf,offset szFromatS,edi
	
	;开始查询
	xor ecx,ecx
	mov eax,[g_count]
CYCLE_MARK:
	cmp ecx,g_count
	je @END
	
	lea esi,[g_person]
	lea edi,[g_strTemPerson.szName]
	mov eax,sizeof(PERSON)
	imul eax,ecx
	add esi,eax
	;比较字符串
	mov eax,ecx;保护外层循环的次数
	mov ecx,6
	repe cmps dword ptr [esi],dword ptr [edi]
	je GOTIT;如果找到
	mov ecx,eax;如果没找到继续外层循环
	inc ecx
	jmp CYCLE_MARK
GOTIT:
	mov ecx,eax
	lea esi,[g_person]
	mov ebx,sizeof(PERSON)
	imul ebx,ecx
	add esi,ebx;esi保存的是要修改的首地址
	lea eax,[esi+PERSON.szNumber]
	invoke crt_printf,eax
	invoke crt_printf,offset szAltNote2;请输入新的号码
	lea eax,[esi+PERSON.szNumber]
	invoke crt_scanf,offset szFromatS,eax
	
@END:	
	invoke crt_printf,offset szAltNote1
	mov esp,ebp
	pop ebp
	ret
	ret

malter endp
main proc
	;char coption=0;用户选项
	LOCAL coption : BYTE
	lea eax,[coption]
	mov eax,0
	call mini
_WHILE:	
	
	push offset szCLS;system("cls")
	call crt_system
	add esp,4
	;print("%s",szWelcom)
	invoke crt_printf,offset szWelcom
	lea eax,[coption];scanf("%c",coption)
	push eax
	push offset szFromatC
	call crt_scanf
	add esp,8

	movsx eax,byte ptr [coption];switch(coption)
	;jmpTable dd _MADD,_MDEL,_MALTER,_MFIND,_MSHOWALL
	cmp eax,031h;coption==1
	je _ADD
	cmp eax,032h;
	je _DEL
	cmp eax,033h
	je _ALTER
	cmp eax,034h
	je _FIND
	cmp eax,035h
	je _SHOW
	cmp eax,036h
	je _END
	jmp _WHILE
	
_ADD:
	call madd;
	call crt_getchar;getchar()
	call crt_getchar;getchar()
	jmp _WHILE
	
_SHOW:
	call mshow
	call crt_getchar;getchar()
	call crt_getchar;getchar()
	jmp _WHILE
	
_FIND:
	call mfind
	call crt_getchar;getchar()
	call crt_getchar;getchar()
	jmp _WHILE
_DEL:
	call mdel
	call crt_getchar;getchar()
	call crt_getchar;getchar()
	jmp _WHILE
	
_ALTER:
	call malter
	call crt_getchar;getchar()
	call crt_getchar;getchar()
	jmp _WHILE
_END:
	call msave
	ret
main endp
entry:
	call main
	ret
end entry
end 