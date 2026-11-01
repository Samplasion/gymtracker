import { handleTrainer } from './handler.ts';
import { strictEqual as assertEquals } from 'node:assert';
import type { SupabaseClient } from 'npm:@supabase/supabase-js@2';
function fake(claims: Record<string,unknown>={role:'authenticated'}, failure:unknown=null) {
 const calls: unknown[]=[];
 return { calls, client: {auth:{getClaims:async()=>({data:{claims},error:null}),getUser:async()=>({data:{user:{id:'verified-user'}},error:null})},rpc:async(name:string,args:unknown)=>{calls.push({name,args});return {data:{ok:true},error:failure}}} as unknown as SupabaseClient};
}
const request=(body:unknown)=>new Request('https://test.invalid/trainer-api',{method:'POST',headers:{Authorization:'Bearer test'},body:JSON.stringify(body)});
Deno.test('delegated OAuth cannot use professional operations',async()=>{
 const f=fake({role:'authenticated',client_id:'external'});const result=await handleTrainer(request({operation:'clients'}),f.client,async()=>{});assertEquals(result.status,401);assertEquals(f.calls.length,0);
});
Deno.test('verified actor replaces any actor supplied by the caller',async()=>{
 const f=fake();await handleTrainer(request({operation:'disconnect',actor:'other'}),f.client,async()=>{});assertEquals((f.calls[0] as {args:{actor:string}}).args.actor,'verified-user');
});
Deno.test('acceptance requires a supported app and refreshes billing server side',async()=>{
 const f=fake();let refreshed=false;
 assertEquals((await handleTrainer(request({operation:'accept'}),f.client,async()=>{refreshed=true})).status,409);assertEquals(refreshed,false);
 assertEquals((await handleTrainer(request({operation:'accept',protocol_version:1,isPro:true}),f.client,async id=>{assertEquals(id,'verified-user');refreshed=true})).status,200);assertEquals(refreshed,true);
});
Deno.test('saturated quota and ended relationships have distinct application errors',async()=>{
 for(const [code,message,status] of [['P1003','exercise_slots_exhausted',402],['P0002','relationship_ended',404]] as const){const f=fake(undefined,{code,message});const result=await handleTrainer(request({operation:'session'}),f.client,async()=>{});assertEquals(result.status,status);assertEquals((await result.json()).error,message);}
});
Deno.test('billing failures never import content',async()=>{
 const f=fake();const response=await handleTrainer(request({operation:'accept',protocol_version:1}),f.client,async()=>{throw {code:'billing_unavailable'}});assertEquals(response.status,503);assertEquals((await response.json()).error,'billing_unavailable');assertEquals(f.calls.length,0);
});

Deno.test('invalid non-consecutive supersets have an actionable application error',async()=>{
 const f=fake(undefined,{code:'22023',message:'noncontiguous_superset'});
 const result=await handleTrainer(request({operation:'publish'}),f.client,async()=>{});
 assertEquals(result.status,400);assertEquals((await result.json()).error,'noncontiguous_superset');
});

Deno.test('billing transport timeouts never claim the client has no connection',async()=>{
 const f=fake();const result=await handleTrainer(request({operation:'accept',protocol_version:1}),f.client,async()=>{throw new DOMException('Timed out','TimeoutError')});
 assertEquals(result.status,503);assertEquals((await result.json()).error,'billing_unavailable');assertEquals(f.calls.length,0);
});

Deno.test('trainer routine size limit has an actionable application error',async()=>{
 const f=fake(undefined,{code:'22023',message:'routine_exercise_limit'});
 const result=await handleTrainer(request({operation:'publish'}),f.client,async()=>{});
 assertEquals(result.status,400);assertEquals((await result.json()).error,'routine_exercise_limit');
});
