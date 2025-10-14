using FlightFinder.API;
using FlightFinder.Shared;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;

namespace FlightFinder.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AirportsController : ControllerBase
    {
        [HttpGet]
        public IEnumerable<Airport> Get()
        {
            return SampleData.Airports;
        }
    }
}
