

rm(list=ls())
nprod<-11

setwd("C:\\Users\\piasa\\OneDrive - Universidad Adolfo Ibanez\\TID")#set work environment to the path were the code and data is stored
demanda<-read.csv("demandadf11OrangeJuice.csv")
demanda<-as.data.frame(demanda)
Prices<-read.csv("Pricesdf11OrangeJuice.csv")
Prices<-as.matrix(Prices)

model <- vector("list", nprod)
for (i in 1:nprod) {
  aux2 <- paste("m", i, sep="_")
  assign(aux2,lm(demanda[,i]~Logprice1 + Logprice2 + Logprice3 + Logprice4+ Logprice5+ Logprice6+ Logprice7+ Logprice8+ Logprice9+ Logprice10+ Logprice11+ Deal1 + Deal2 +Deal3 + Deal4 + Deal5+ Deal6+ Deal7+ Deal8+ Deal9+ Deal10+ Deal11 + Feat1+Feat2+Feat3+Feat4+Feat5+Feat6+Feat7+Feat8+Feat9+Feat10+Feat11,data=demanda)) #con + is multiple linear regression
  
}


model[[1]] <- m_1
model[[2]] <- m_2
model[[3]] <- m_3
model[[4]] <- m_4
model[[5]] <- m_5
model[[6]] <- m_6
model[[7]] <- m_7
model[[8]] <- m_8
model[[9]] <- m_9
model[[10]] <- m_10
model[[11]] <- m_11


Precio <- Prices[1,]
Precio_ultimo<-Prices[nrow(Prices),]
f_venta <- function(Precio) {
  lp=as.data.frame(t(log(Precio))) 
  lp <- cbind(lp, matrix(0, nrow = nrow(lp), ncol = 22))
  colnames(lp)=c("Logprice1", "Logprice2", "Logprice3", "Logprice4", "Logprice5", "Logprice6", "Logprice7", "Logprice8", "Logprice9", "Logprice10", "Logprice11", "Deal1", "Deal2","Deal3","Deal4", "Deal5", "Deal6", "Deal7", "Deal8", "Deal9", "Deal10", "Deal11", "Feat1", "Feat2", "Feat3","Feat4","Feat5","Feat6","Feat7","Feat8","Feat9","Feat10","Feat11")  
  venta <- 0
  for (i in 1:nprod ) { 
    v<- Precio[i]*round(exp(predict(model[[i]],data.frame(lp)))) #venta=P*Q
    venta <- venta + v
  }
  return(venta)
}
f_venta(Precio_ultimo) #función ingreso por ventas

preciomin <- apply(Prices, 2, function(x) min(x, na.rm = TRUE))
preciomax <- apply(Prices, 2, function(x) max(x, na.rm = TRUE))

#restricciones
ui <- matrix(1,nrow=2,ncol=11)
ui[2,] <- c(-1,-1,-1,-1, -1,-1,-1,-1,-1,-1,-1)
ci <- c((mean(rowMeans(Prices))*11)*0.9,-(mean(rowMeans(Prices))*11)*1.1) #promedio de los 4 productos 

u2 <- diag(1,11,11)
u3 <- -u2

uu <- rbind(ui,u2,u3) 
cc <- rbind(as.matrix(ci),as.matrix(preciomin),-as.matrix(preciomax))
cc
aux3=rbind(as.matrix(ci), as.matrix(rep(0,nprod)))

# Simulaciones
set.seed("301")

#f_optim for graph
f_optim_time <- function(ui,ci,niter) {
  
  message=FALSE
  warning=FALSE
  suppressMessages(library(limSolve))
  aux=diag(nprod)
  aux2=rbind(ui,aux)
  aux3=rbind(as.matrix(ci), as.matrix(rep(0,nprod)))
  dim(aux2)
  precio1=xsample(G=aux2, H=aux3)
  precio2=precio1$X[nrow(precio1$X),] #x es matrix with the sampled values of x
  
  precio=0
  pi=0 #valor z*
  iter=0
  pi_values = numeric(niter) #vector con los valor candidatos de z
  time_difference<-numeric(niter)
  pi_incumbent<-numeric(niter)
  for(i in 1:niter) {
    start_time <- Sys.time() 
    precio2=precio1$X[nrow(precio1$X)-i,]
    p_prod <- constrOptim(precio2, f_venta, NULL, ui=ui, ci=ci, control=list(fnscale=-1))
    print(c(i, pi,p_prod$value))
    pi_values[i] = p_prod$value #value es el z*
    if (p_prod$value> pi) { #estamos maximizando entonces se compara con el z actual para ver si es más grande y se actualiza si sí 
      pi= p_prod$value 
      iter=i
      precio=p_prod$par #x*
      value_over_f_venta = pi / f_venta(Precio) #proporción entre el ingreso por venta
      par_over_precio = precio / Precio #proporción entre precios
    } 
    end_time <- Sys.time()
    time_difference[i] <- difftime(end_time, start_time, units = "mins")
    pi_incumbent[i]<-pi
  }
  pi_sd = sd(pi_values) #standar deviation
  print(c(iter,pi, pi_sd, precio, value_over_f_venta, par_over_precio))
  result=list(iter=iter, pi=pi, pi_sd=pi_sd, pi_values=pi_values, pi_incumbent=pi_incumbent ,time_iter=time_difference, precio=precio, value_over=value_over_f_venta, par_over=par_over_precio)
  return(result)
}


start_time <- Sys.time()
constrOptim_time<- f_optim_time(uu,cc,17) 
end_time <- Sys.time()
end_time - start_time

cumulative_time <- cumsum(constrOptim_time$time_iter)
print(cumulative_time)


# GRAPH 
result_df <- data.frame(pi_values = constrOptim_time$pi_values, pi_incumbent=constrOptim_time$pi_incumbent, time_iter = cumulative_time)
write.csv(result_df, file = "data11dfGraphR_iter17.csv", row.names = TRUE)
library(ggplot2)
# Plotting the graph
ggplot(result_df, aes(x = time_iter, y = pi_incumbent)) +
  geom_line() +
  labs(title = "z Values Over Time", x = "Time seconds", y = "Pi Values")

