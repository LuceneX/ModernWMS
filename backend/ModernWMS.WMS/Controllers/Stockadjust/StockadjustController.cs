/*
 * date：2022-12-26
 * developer：NoNo
 */
 using Microsoft.AspNetCore.Mvc;
 using ModernWMS.Core.Controller;
 using ModernWMS.Core.Models;
 using ModernWMS.WMS.Entities.ViewModels;
 using ModernWMS.WMS.IServices;
 using Microsoft.Extensions.Localization;
namespace ModernWMS.WMS.Controllers
{
    /// <summary>
    /// stockadjust controller
    /// </summary>
     [Route("stockadjust")]
     [ApiController]
     [ApiExplorerSettings(GroupName = "WMS")]
     public class StockadjustController : BaseController
     {
         #region Args
 
         /// <summary>
         /// stockadjust Service
         /// </summary>
         private readonly IStockadjustService _stockadjustService;
 
         /// <summary>
         /// Localizer Service
         /// </summary>
         private readonly IStringLocalizer<ModernWMS.Core.MultiLanguage> _stringLocalizer;
         #endregion
 
         #region constructor
         /// <summary>
         /// constructor
         /// </summary>
         /// <param name="stockadjustService">stockadjust Service</param>
        /// <param name="stringLocalizer">Localizer</param>
         public StockadjustController(
             IStockadjustService stockadjustService
           , IStringLocalizer<ModernWMS.Core.MultiLanguage> stringLocalizer
             )
         {
             this._stockadjustService = stockadjustService;
            this._stringLocalizer= stringLocalizer;
         }
         #endregion
 
         #region Api
         /// <summary>
         /// page search
         /// </summary>
         /// <param name="pageSearch">args</param>
         /// <returns></returns>
         [HttpPost("list")]
         public async Task<ResultModel<PageData<StockadjustViewModel>>> PageAsync(PageSearch pageSearch)
         {
             var (data, totals) = await _stockadjustService.PageAsync(pageSearch, CurrentUser);
              
             return ResultModel<PageData<StockadjustViewModel>>.Success(new PageData<StockadjustViewModel>
             {
                 Rows = data,
                 Totals = totals
             });
         }

        /// <summary>
        /// get all adjustment records for the current tenant
        /// </summary>
        [HttpGet("all")]
        public async Task<ResultModel<List<StockadjustViewModel>>> GetAllAsync()
        {
            var data = await _stockadjustService.GetAllAsync(CurrentUser);
            return ResultModel<List<StockadjustViewModel>>.Success(data ?? new List<StockadjustViewModel>());
        }

        /// <summary>
        /// get one adjustment record
        /// </summary>
        [HttpGet]
        public async Task<ResultModel<StockadjustViewModel>> GetAsync(int id)
        {
            var data = await _stockadjustService.GetAsync(id);
            return data == null
                ? ResultModel<StockadjustViewModel>.Error(_stringLocalizer["not_exists_entity"])
                : ResultModel<StockadjustViewModel>.Success(data);
        }

        /// <summary>
        /// create an adjustment record
        /// </summary>
        [HttpPost]
        public async Task<ResultModel<int>> AddAsync(StockadjustViewModel viewModel)
        {
            var (id, msg) = await _stockadjustService.AddAsync(viewModel, CurrentUser);
            return id > 0
                ? ResultModel<int>.Success(id)
                : ResultModel<int>.Error(msg);
        }

        /// <summary>
        /// update an unconfirmed adjustment record
        /// </summary>
        [HttpPut]
        public async Task<ResultModel<bool>> UpdateAsync(StockadjustViewModel viewModel)
        {
            var (flag, msg) = await _stockadjustService.UpdateAsync(viewModel);
            return flag
                ? ResultModel<bool>.Success(flag)
                : ResultModel<bool>.Error(msg, 400, flag);
        }

        /// <summary>
        /// delete an adjustment record
        /// </summary>
        [HttpDelete]
        public async Task<ResultModel<string>> DeleteAsync(int id)
        {
            var (flag, msg) = await _stockadjustService.DeleteAsync(id);
            return flag
                ? ResultModel<string>.Success(msg)
                : ResultModel<string>.Error(msg);
        }

        /// <summary>
        /// apply an adjustment to stock
        /// </summary>
        [HttpPut("confirm")]
        public async Task<ResultModel<bool>> ConfirmAdjustment(int id)
        {
            var (flag, msg) = await _stockadjustService.ConfirmAdjustment(id);
            return flag
                ? ResultModel<bool>.Success(flag)
                : ResultModel<bool>.Error(msg, 400, flag);
        }
 
        #endregion

    }
 }
 
