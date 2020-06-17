struct GradStep <: MPSKit.Algorithm
end

function MPSKit.timestep(state::FinPEPS, H::NN, timestep::Number,alg::GradStep,pars::FinNNHamChannels)
    newpeps = copy(state);
    for (i,j) in Iterators.product(1:size(state,1),1:size(state,2))
        (h_eff,n_eff) = effectivehn(pars,i,j)
        v = permute(state[i,j],(1,2,3,4,5))

        n_eff = reginv(n_eff)

        g = n_eff*h_eff*v
        newpeps[i,j]+=-1im*timestep*permute(g,(1,2,3,4),(5,));
        normalize!(newpeps[i,j])
    end

    newpars = deepcopy(pars);

    MPSKit.recalculate!(newpars,newpeps)

    return newpeps,newpars
end

function reginv(m, delta=real(zero(eltype(m))))
    delta = max(delta, sqrt(eps(real(float(one(eltype(m)))))))
    U, S, Vdg = tsvd(m)
    Sinv = inv(real(sqrt(S^2 + delta^2*one(S))))
    minv = Vdg' * Sinv * U'
    return minv
end
