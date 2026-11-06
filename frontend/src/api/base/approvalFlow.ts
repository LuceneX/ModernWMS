import http from '@/utils/http/request'

/** Approval-flow configuration API. Transaction approval execution remains
 * owned by the operation that consumes the configured flow. */
export const getApprovalFlows = () => http({
  url: '/approve/flowset',
  method: 'get'
})

export const getApprovalFlowMap = (id: number) => http({
  url: `/approve/flowset/${id}/map`,
  method: 'get'
})

export const createApprovalFlow = (data: Record<string, unknown>) => http({
  url: '/approve/flowset',
  method: 'post',
  data
})

export const deleteApprovalFlow = (id: number) => http({
  url: `/approve/flowset/${id}`,
  method: 'delete'
})
