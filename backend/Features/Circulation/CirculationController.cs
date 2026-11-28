using Microsoft.AspNetCore.Mvc;

namespace TecNM.Api.Features.Circulation;

[ApiController]
[Route("api/[controller]")]
public sealed class CirculationController(ICirculationService circulationService) : ControllerBase
{
    [HttpGet("loans")]
    public async Task<ActionResult<CirculationSummaryDto>> GetCirculationSummary()
    {
        var summary = await circulationService.GetCirculationSummaryAsync();
        return Ok(summary);
    }

    [HttpPost("loans")]
    public async Task<ActionResult<CirculationLoanDto>> CreateLoan([FromBody] CreateLoanRequest req)
    {
        var (loan, error, isConflict) = await circulationService.CreateLoanAsync(req);
        if (error is not null)
        {
            return isConflict
                ? Conflict(new { message = error })
                : BadRequest(new { message = error });
        }

        return Ok(loan);
    }

    [HttpPut("loans/{id:int}/return")]
    public async Task<ActionResult<CirculationLoanDto>> ReturnLoan(int id)
    {
        var (loan, error, isNotFound) = await circulationService.ReturnLoanAsync(id);
        if (isNotFound)
        {
            return NotFound(new { message = error });
        }

        if (error is not null)
        {
            return BadRequest(new { message = error });
        }

        return Ok(loan);
    }

    [HttpPut("loans/{id:int}/renew")]
    public async Task<ActionResult<CirculationLoanDto>> RenewLoan(int id)
    {
        var (loan, error, isNotFound) = await circulationService.RenewLoanAsync(id);
        if (isNotFound)
        {
            return NotFound(new { message = error });
        }

        if (error is not null)
        {
            return BadRequest(new { message = error });
        }

        return Ok(loan);
    }
}
