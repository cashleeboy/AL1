//
//  APIConfig.swift
//  AL1
//
//  Created by cashlee on 2025/12/23.
//

import Foundation

struct APIConfig {
    
    // MARK: - API Paths (路径管理)
    struct Path {
        struct Project {
            static let initialConfig = "/mWzH4qWbY0Aox/pFSVwCin0G/m85M68kW3i"
            
            // 获取风控数据过滤规则
            static let sysConfig = "/hfqwj9bDWEN/g9Jton7_Kw/f8TdnUSh5"
            
            // 提交客户上传数据 Submit customer uploaded data
            static let submitCustomerData = "/auy6_kj0Dajr/qC_uweYfsjM/gDDWbf"
            static let feedbackInfo = "/gZ2VBtAYnEeuA/uvA_7/ax1Wf/sCpOPuNcW"
        }
        
        // home
        struct Loan {
            static let homeSearch = "/k61ybqx5l5/tQA4XToikfJ3/xXOH_nABohDVx/dL7Hndvk0y"
            static let recommendInfo = "/oFYsT5JHoF/cglwb_6QBX/zRgAOCxw43/z36XIzoSIdGtC"
            static let comfirmLoan = "/naiPUGj/cF_eRxBwKS/eoL9w3j6qV41H"
            static let applySuccess = "/c3YdW/pYAHH/t0Do"
        }
        
        struct Auth {
            static let sendAuthCode = "/i2uWV/gcbPVmdr11VAk/jBN53yNlEyO"
            static let login = "/rClMM/rGlXyx1xahEKl/rc_aQ2TNcojy/rtuYR"
            static let logout = "/fsH4RFP/tYzx4q4P1c/jex9FZGVW/uYPS"
            static let cancelUserAccount = "/rAWPJ3VD/p931/y0fl46o"
            static let userInfo = "/oANVUQ/mHIwucxNy8/riQybEyzesv"
            static let serviceInfoInquiry = "/isbe2erZ3QdIt/krc8Nk/iMws3BRd/rzlVjwn"
            
            static let submitPersonalInfo = "/lUOMw/v0quITBRp6i1d/y_229b/tlv1FkX"
            static let submitContacts = "/w0eTEOceSfn/fEEzolAte0O/lkw79Ak"
            static let submitBankInfo = "/aCm9/o53QknXH/t64AIvJK/aRF9"
        }
        
        struct Apply {
            // 获取进件进度
            static let getAuthStatus = "/h3DjGkMiIsD/iP9ox1Tg/rBZTLK1bDyYBV/pJpHE"
            static let dataIsValid = "/doum/mvDOd0RBz/ogtf"
            
            // 个人信息项 (Personal Info)
            static let submitPersonalInfo = "/lUOMw/v0quITBRp6i1d/y_229b/tlv1FkX"
            static let queryPersonalInfo = "/qrh2/zqzPBx1lTwK4/bEBRWwkWi1/omU7iF"
            
            // 联系人 (Contacts)
            static let submitContacts = "/w0eTEOceSfn/fEEzolAte0O/lkw79Ak"
            static let queryContacts = "/raKEOlCH/vubUlwz8hOc/lojSR/nDr5S1pANCf"
            
            // 银行卡 (Bank Card)
            static let submitBankInfo = "/aCm9/o53QknXH/t64AIvJK/aRF9"
            static let queryBankInfo = "/zNIYVlouy2ssm/il2n2vhQk/oQPQ/zhfJ8U"
            
            // OCR 进件信息 (OCR Form Data)
            static let submitOCRInfo = "/dS2bhA/kuKsiV/t0gSl278m8p38"
            static let queryOCRInfo = "/gmJvM/xsp8/q1oliI_YR_2/bpGPI"
            
            // 人脸与 OCR 校验 (Verification)
            static let faceRecognition = "/mA6tDq0m/ogxz/rZjEoVc8/esFXg_4jR_ul"
            static let customerOCRVerify = "/lnkJ174qX/lq8SxQ0XytUv0/ewd4"
            
            // 行政区域配置查询
            static let regionConfigQuery = "/mEJL_sFaj/whY7/l9C18Gk"
        }
        
        struct BankApi {
            
            // 获取用户银行卡列表
            static let userBankList = "/kPjauhlWc/za63L/jc05RPxBw_cx"
            // 查询银行名称列表
            static let bankListQuery = "/eFhN5mrd8p5/gV8k/nMJkUrlxW/yyJh"
            // 提交银行卡信息-个人银行卡页面
            static let submitBankInfo = "/wJioSWWslmm/jBDVcTPGXh/gRKX0Jps/taCa"
            // 删除银行卡信息
            static let deleteBankInfo = "/fkua8J5ydw8e/psX_ti7C/hUUhP4wVXj"
            // 修改银行卡重新放款-首页订单状态51
            static let queryBankCard = "/k8iBc/eErNrty/qTYz2qvJ9Rs7k"
        }
        
        struct Order {
            static let orderList = "/xQEJOacqSMl9x/abTxN/wW1O/zE316onZ"
            static let orderDetail = "/gCV_cn/dT3Eu8EWNEc/mKS2vPGgC49zU/mt55aNv"
        }
    }
    

}
