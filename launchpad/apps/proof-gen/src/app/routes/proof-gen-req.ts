import { FastifyPlugin } from "fastify"
import { parentPort } from "worker_threads";
import process from "process";


export enum ProofTaskType {
  SALE_BATCH_MERGE = 0,

  PRESALE_CONTRACT_MAINTAIN_CONTRIBUTORS = 1,
  FAIRSALE_CONTRACT_MAINTAIN_CONTRIBUTORS = 2,
  PRIVATESALE_CONTRACT_MAINTAIN_CONTRIBUTORS = 3,

  CLIENT_AIRDROP_PROOF_REQ = 4,
  CLIENT_PRESALE_CONTRIBUTE_PROOF_REQ = 5,
  CLIENT_PRESALE_CLAIM_TOKEN_PROOF_REQ = 6,
  CLIENT_PRESALE_REDEEM_FUND_PROOF_REQ = 7,

  CLIENT_FAIRSALE_CONTRIBUTE_PROOF_REQ = 8,
  CLIENT_FAIRSALE_CLAIM_TOKEN_PROOF_REQ = 9,

  CLIENT_PRIVATESALE_CLAIM_PROOF_REQ = 10,
  CLIENT_PRIVATESALE_CONTRIBUTE_PROOF_REQ = 11,
  CLIENT_PRIVATESALE_REDEEM_FUND_PROOF_REQ = 12,

}

export interface ProofTaskDto<S, T> {
  taskType: ProofTaskType,
  index: S
  payload: T
}


/**
* recieve proof-gen req from 'deposit-processor' & 'sequencer'
*/
export const proofGenReqEndpoint: FastifyPlugin = async function(
  instance,
  options,
  done
): Promise<void> {
  instance.route({
    method: "POST",
    url: "/proof-gen",
    //preHandler: [instance.authGuard],
    schema,
    handler
  })
}

const handler: RequestHandler<ProofTaskDto<any, any>, null> = async function(
  req,
  res
): Promise<BaseResponse<string>> {
  const { taskType, index, payload } = req.body;

  (process as any).send({
    taskType,
    index,
    payload: req.body.payload.data
  });

  return {
    code: 0,
    data: '',
    msg: ''
  };
}

const schema = {
  description: 'recieve proof-gen req from \'deposit-processor\' & \'sequencer\'',
  tags: ["Proof"],
  body: {
    type: "object",
    properties: (ProofTaskDtoSchema as any).properties,
  },
  response: {
    200: {
      type: "object",
      properties: {
        code: {
          type: 'number',
          description: '0: success, 1: failure.'
        },
        data: {
          type: 'string'
        },
        msg: {
          type: 'string',
          description: 'the reason or msg related to \'code\''
        }
      },
    }
  }
}
